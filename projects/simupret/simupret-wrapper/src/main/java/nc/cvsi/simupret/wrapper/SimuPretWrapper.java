package nc.cvsi.simupret.wrapper;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.lang.ProcessBuilder.Redirect;

import com.fasterxml.jackson.databind.ObjectMapper;

import nc.cvsi.simupret.entity.DemandePret;
import nc.cvsi.simupret.exceptions.ProcessBuilderException;
import nc.cvsi.simupret.exceptions.ProcessException;
import nc.cvsi.simupret.exceptions.ProcessInterruptedException;

public class SimuPretWrapper {
    private ProcessBuilder simuProcessBuilder;
    private Process simuProcess;
    private DemandePret demandePret;

    public SimuPretWrapper(DemandePret demandePret) {
        this.demandePret = demandePret;
    }

    public Process getProcess() {
        return this.simuProcess;
    }

    // Creer le processBuilder
    public void createProcessBuilder(String command, String argument, File fDirectory) {

        this.simuProcessBuilder = new ProcessBuilder();
        // mis à jour de la commande
        if (command.isEmpty())
            throw new ProcessBuilderException("La commande du processBuilder est invalide");
        if (argument.isEmpty()) {
            throw new ProcessBuilderException("L'argument du processBuilder est invalide");
        }
        this.simuProcessBuilder.command(command, argument);

        // mis à jour de CWD du sous-process
        if (fDirectory == null)
            throw new ProcessBuilderException("Le Current Work Directory du sous processus est invalide");
        this.simuProcessBuilder.directory(fDirectory);

        // Configuration des flux standards
        // flux de sortie du sous-process redirigé vers le flux de sortie du process
        // maître
        this.simuProcessBuilder.redirectOutput(Redirect.INHERIT);
        // flux d'erreur du sous-process redirigé vers le flux d'erreur du process
        // maître
        this.simuProcessBuilder.redirectError(Redirect.INHERIT);
    }

    public int startProcess() {
        int simuReturnCode;
        if (this.simuProcessBuilder == null) {
            throw new NullPointerException("Le process builder est invalide");
        }

        try {
            this.simuProcess = simuProcessBuilder.start();
            System.out.println("Process COBOL Démarré avec le PID : " + simuProcess.pid());

            // Alimenter le flux d'entrée du sous-process (stdin) via la sortie du process
            // maître
            try (OutputStream simuInputStream = simuProcess.getOutputStream()) {
                String simulatedInput = new String(
                        demandePret.getTypePret() + "\n" + demandePret.getCapital() + "\n" + demandePret.getDuree()
                                + "\n");
                byte[] simulatedInputBytes = simulatedInput.getBytes();
                simuInputStream.write(simulatedInputBytes);
            }

            // Récupérer le code de sortie du sous-process
            simuReturnCode = simuProcess.waitFor();
            System.out.println("SIMUPRET => Return Code : " + simuReturnCode);
            return simuReturnCode;

        } catch (IOException ioE) {
            throw new ProcessException("Le sous-Process rencontre une problème ", ioE);
        } catch (InterruptedException iE) {
            // on détruit l'execution du cobol
            simuProcess.destroy();
            // on releve le drapeau pour le thread
            Thread.currentThread().interrupt();
            // indiquer que le process est interrompu
            throw new ProcessInterruptedException("Le sous-Process est interrompu ", iE);
        }
    }

    @SuppressWarnings("unchecked")
    public <T> T parseJson(File fileToParse, Class<T> jsonDataModel) {
        T spwData = (T) new SimuPretWrapperData();

        ObjectMapper simuPretObjectMapper = new ObjectMapper();
        try {
            spwData = simuPretObjectMapper.readValue(
                    fileToParse,
                    jsonDataModel);
        } catch (IOException ioE) {
            throw new ProcessException("Lecture Mapper JSON en echec " + ioE.getMessage());
        }

        return (T) spwData;
    }
}
