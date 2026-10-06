package nc.cvsi.simupret.httpserver;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.net.InetSocketAddress;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.time.Instant;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.exc.StreamReadException;
import com.fasterxml.jackson.databind.DatabindException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.exc.InvalidDefinitionException;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;

import nc.cvsi.simupret.SimuPretConfig;
import nc.cvsi.simupret.entity.DemandePret;
import nc.cvsi.simupret.exceptions.CapitalException;
import nc.cvsi.simupret.exceptions.DureeException;
import nc.cvsi.simupret.exceptions.ProcessBuilderException;
import nc.cvsi.simupret.exceptions.ProcessException;
import nc.cvsi.simupret.exceptions.ProcessInterruptedException;
import nc.cvsi.simupret.exceptions.TypePretException;
import nc.cvsi.simupret.wrapper.SimuPretWrapper;
import nc.cvsi.simupret.wrapper.SimuPretWrapperData;

public class SimuPretHttpServer {
    private final HttpServer simuPretHttpServer;
    private static final String OK_ROUTE = "/OK";
    private static final String SIMUPRET_ROUTE = "/simupret";
    private static final Set<String> ALLOWED_METHODS = Set.of("POST");

    private static final Path simuPretCWD = Path.of(System.getenv("SIMUPRET_CBL_CWD"));
    private static final Path simuPretExec = Path.of(System.getenv("SIMUPRET_CBL_EXEC"));
    private static final Path simuPretJSON = Path.of(System.getenv("SIMUPRET_CBL_CWD"),
            System.getenv("SIMUPRET_CBL_JSON"));

    private final InetSocketAddress socketAddress;
    private final SimuPretConfig spg;

    // Nom du fichier json
    String jsonFileName;
    // Path du fichier json
    Path jsonFilePath;

    // Step 1: Create an HttpServer instance.
    // Step 2: Create a context and set the handler.
    // Step 3: Start the server.
    // Step 4: Handle the request.
    public SimuPretHttpServer(SimuPretConfig spg) throws IOException {
        // On récupere la config
        this.spg = spg;

        // On crée l'adresse d'écoute sur tous les périphériques réseau disponible sur
        // le port ':port'
        socketAddress = new InetSocketAddress(spg.port());

        // On crée le serveur qui écoute sur l'adresse.
        // backlog = 0 : file d'attente par défaut, gérée par l'OS.
        this.simuPretHttpServer = HttpServer.create(socketAddress, 0);

        // On crée la route (Context) et on l'associe à un Handler
        // /OK
        this.simuPretHttpServer.createContext(OK_ROUTE, this::handleOK);
        // /simupret
        this.simuPretHttpServer.createContext(SIMUPRET_ROUTE, this::handleSimuPret);

        // Executors : permet d'avoir plusieurs contextes fonctionnant en meme temps
        // grace au thread
        ExecutorService executorService = Executors.newFixedThreadPool(2);
        this.simuPretHttpServer.setExecutor(executorService);
    }

    public void start() {
        // On démarre le serveur
        this.simuPretHttpServer.start();
        System.out.println(
                "Serveur démarré sur le port : " + socketAddress.getHostString() + ":" + socketAddress.getPort());
    }

    private void handleOK(HttpExchange exchange) throws IOException {
        try {
            sendJsonResponse(exchange, 200, jsonMessage("OK"));
        } finally {
            exchange.close();
        }
    }

    private void handleSimuPret(HttpExchange exchange) throws IOException {
        String methodRecue = exchange.getRequestMethod();
        String cheminRecu = exchange.getRequestURI().getPath();
        System.out.println(methodRecue);
        System.out.println("URI = " + exchange.getRequestURI().toString());
        System.out.println("Path = " + cheminRecu);
        ObjectMapper ob = new ObjectMapper();
        DemandePret demandePret;
        SimuPretWrapper simuPret;
        String simuPretJsonResponseBody;

        try {
            // Vérifier la route
            if (!SIMUPRET_ROUTE.equals(cheminRecu)) {
                // 404 - Ressource not found
                sendJsonResponse(exchange, 404, jsonError("Ressource introuvable"));
                return;
            }

            // Vérifier la méthode
            if (!ALLOWED_METHODS.contains(methodRecue)) {
                // 405 method non autorisé
                // La réponse Http doit contenir les Methodes autorisées via Allow
                exchange.getResponseHeaders().set("Allow", String.join(",", ALLOWED_METHODS));
                sendJsonResponse(exchange, 405, jsonError("Méthode non autorisée"));
                return;
            }

            // Extraire les paramètres d'appel en fonction de la méthode
            try (InputStream is = exchange.getRequestBody()) {
                demandePret = ob.readValue(is, DemandePret.class);
                System.out.println("POST REQUEST BODY : " + demandePret);
            } catch (InvalidDefinitionException ide) {
                sendJsonResponse(exchange, 500, jsonError("Erreur interne"));
                return;
            } catch (StreamReadException sre) {
                // Le texte n'est peut être pas du json => 400
                sendJsonResponse(exchange, 400, jsonError("Le format de la requete n'est pas correcte"));
                return;
            } catch (DatabindException de) {
                sendJsonResponse(exchange, 400, jsonError("Le format de la requete n'est pas correcte"));
                return;
            } catch (CapitalException | DureeException | TypePretException e) {
                sendJsonResponse(exchange, 400, jsonError("Le format de la requete n'est pas correcte"));
                return;
            }

            // Verifier si la demande de pret est valide
            if (demandePret.getTypePret() != 'A' && demandePret.getTypePret() != 'C'
                    && demandePret.getTypePret() != 'I') {
                sendJsonResponse(exchange, 400, jsonError("Le format de la requete n'est pas correcte"));
                return;
            }
            if (demandePret.getCapital() == null || demandePret.getCapital().compareTo(BigDecimal.ZERO) <= 0) {
                sendJsonResponse(exchange, 400, jsonError("Le format de la requete n'est pas correcte"));
                return;
            }
            if (demandePret.getDuree() <= 0) {
                sendJsonResponse(exchange, 400, jsonError("Le format de la requete n'est pas correcte"));
                return;
            }

            // APPEL DU PROCESS BUILDER
            int returnCode;
            try {
                // creation du nom de fichier Json
                jsonFileName = "simu-" + UUID.randomUUID() + ".json";
                System.out.println("Le nom du fichier JSON : " + jsonFileName);
                jsonFilePath = simuPretCWD.resolve(jsonFileName);

                // Exécution de la demande de pret
                simuPret = new SimuPretWrapper(demandePret);
                simuPret.createProcessBuilder(simuPretExec.toString(), jsonFileName, simuPretCWD.toFile());
                Instant startInstant = Instant.now();
                returnCode = simuPret.startProcess();
                Instant stopInstant = Instant.now();
                Duration dureeExex = Duration.between(startInstant, stopInstant);

                System.out.println("Durée Cobol : " + dureeExex + "sec?");
                System.out.println("Durée Cobol : " + dureeExex.toMillis());
                System.out.println("Return code SIMUPRET : " + returnCode);
            } catch (ProcessInterruptedException pie) {
                // ProcessInterruptedException doit arriver avant tout ProcessException sinon
                // intercepté par ce dernier (Heritage)
                boolean interrompu = Thread.interrupted();
                sendJsonResponse(exchange, 503, jsonError("Traitement interrompu, réessayez plus tard"));
                if (interrompu)
                    Thread.currentThread().interrupt();
                return;
            } catch (ProcessBuilderException pbe) {
                // une erreur dans la construction du process. la requete http a bien été
                // interpretée. => 500 Internal Error
                sendJsonResponse(exchange, 500, jsonError("La simulation de pret indisponible"));
                return;
            } catch (ProcessException pe) {
                sendJsonResponse(exchange, 500, jsonError("Echec lors de la simulation de pret"));
                return;
            }

            // si le process ne se termine pas avec un RC=0 alors 500
            if (returnCode != 0) {
                sendJsonResponse(exchange, 500, jsonError("La simulation de pret a échoué"));
                return;
            }

            // On déserialise le json en SimuPretWrapperData
            SimuPretWrapperData spwd = simuPret.parseJson(jsonFilePath.toFile(), SimuPretWrapperData.class);

            // On repasse en json pour l'exercice
            try {
                simuPretJsonResponseBody = ob.writeValueAsString(spwd);
            } catch (JsonProcessingException jpe) {
                sendJsonResponse(exchange, 500, jsonError("La simulation de pret a échoué"));
                return;
            }

            // on supprime le fichier de la simulation
            try {
                Files.deleteIfExists(jsonFilePath);

            } catch (SecurityException | IOException e) {
                System.err.println("Impossible de supprimer le fichier : " + jsonFileName + " => " + e);
            }

            // Créer la réponse 200-OK
            sendJsonResponse(exchange, 200, simuPretJsonResponseBody);

        } finally {
            exchange.close();
        }
    }

    // Cette méthode permet de créer la réponse à la requete (exchange)
    private void sendResponse(HttpExchange exchange, int httpStatus, String response, String contentType)
            throws IOException {

        // Construire le header de la réponse
        exchange.getResponseHeaders().set("Content-Type", contentType + "; charset=utf-8");
        if ("HEAD".equals(exchange.getRequestMethod())) {
            exchange.sendResponseHeaders(httpStatus, -1);
            return;
        }
        exchange.sendResponseHeaders(httpStatus, response.getBytes().length);

        // Ecrire la réponse
        try (OutputStream os = exchange.getResponseBody()) {
            os.write(response.getBytes());
        }
    }

    private void sendJsonResponse(HttpExchange exchange, int httpStatus, String jsonResponse) throws IOException {
        this.sendResponse(exchange, httpStatus, jsonResponse, "application/json");
    }

    private static String jsonError(String message) {
        return "{\"erreur\":\"" + message + "\"}";
    }

    private static String jsonMessage(String message) {
        return "{\"message\":\"" + message + "\"}";
    }
}
