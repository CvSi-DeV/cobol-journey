package nc.cvsi.simupret;

import java.io.IOException;

import nc.cvsi.simupret.exceptions.SimuPretHttpServerException;
import nc.cvsi.simupret.httpserver.SimuPretHttpServer;

/**
 * Hello Simupret!
 */
public class App {
    public static void main(String[] args) {
        System.out.println("Hello Simupret!");

        // chargement des variables de configuration
        SimuPretConfig spg = SimuPretConfig.fromEnvironment();

        System.out.println("Création du Serveur HTTP");
        try {
            // construction du serveur
            SimuPretHttpServer sphs = new SimuPretHttpServer(spg);
            // démarrage du serveur
            sphs.start();
        } catch (IOException ioe) {
            throw new SimuPretHttpServerException(ioe.getClass().getName() + " " + ioe.getMessage());
        }
    }
}
