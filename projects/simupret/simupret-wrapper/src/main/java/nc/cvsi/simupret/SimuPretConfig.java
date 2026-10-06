package nc.cvsi.simupret;

import java.nio.file.Path;

public record SimuPretConfig(
        int port,
        Path currentWorkDirectory,
        Path exec) {
    public static SimuPretConfig fromEnvironment() {
        int port;
        try {
            port = Integer.parseInt(mandatoryRead("SIMUPRET_SERVER_PORT"));
        } catch (NumberFormatException nfe) {
            throw new IllegalStateException("\"SIMUPRET_SERVER_PORT\"" + "doit être un entier représentant un port");
        }
        Path currentWorkDirectory = Path.of(mandatoryRead("SIMUPRET_CBL_CWD"));
        Path exec = Path.of(mandatoryRead("SIMUPRET_CBL_EXEC"));
        return new SimuPretConfig(port, currentWorkDirectory, exec);
    }

    // oblige la présence de la variable d'environnement
    private static String mandatoryRead(String nom) {
        String valeur = System.getenv(nom);
        if (valeur == null || valeur.isBlank()) {
            throw new IllegalStateException("Variable d'environnement absente : " + nom);
        }
        return valeur;
    }
}
