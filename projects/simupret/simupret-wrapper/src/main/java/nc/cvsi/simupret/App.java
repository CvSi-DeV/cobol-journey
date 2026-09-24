package nc.cvsi.simupret;

import java.io.File;
import java.math.BigDecimal;
import java.nio.file.Path;

import nc.cvsi.simupret.entity.DemandePret;
import nc.cvsi.simupret.wrapper.SimuPretWrapper;
import nc.cvsi.simupret.wrapper.SimuPretWrapperData;

/**
 * Hello Simupret!
 */
public class App {
    public static void main(String[] args) {
        System.out.println("Hello Simupret!");

        Path simuPretCWD = Path.of(System.getenv("SIMUPRET_CBL_CWD"));
        System.out.println(simuPretCWD.toString());
        Path simuPretExec = Path.of(System.getenv("SIMUPRET_CBL_EXEC"));
        System.out.println(simuPretExec.toString());
        Path simuPretJSON = Path.of(System.getenv("SIMUPRET_CBL_CWD"), System.getenv("SIMUPRET_CBL_JSON"));
        System.out.println(simuPretJSON.toString());

        // Premiere demande de pret
        // Type de pret -> A
        // Capital -> 25000
        // Durée -> 5
        DemandePret demandePretAuto = new DemandePret('A', new BigDecimal("25000.00"), 5);
        // Exécution de la demande de pret AUTO
        SimuPretWrapper simuPretAuto = new SimuPretWrapper(demandePretAuto);
        simuPretAuto.createProcessBuilder(simuPretExec.toString(), simuPretCWD.toFile());
        if (simuPretAuto.startProcess() == 0) {
            // Parser le fichier JSON
            File jsonFile = simuPretJSON.toFile();
            SimuPretWrapperData spwDataAuto = simuPretAuto.parseJson(jsonFile, SimuPretWrapperData.class);
            System.out.println(spwDataAuto.toString());
        }

        // Seconde demande de pret
        // Type de pret -> I
        // Capital -> 200000
        // Durée -> 20
        DemandePret demandePretImmo = new DemandePret('I', new BigDecimal("200000"), 20);
        SimuPretWrapper simupretImmo = new SimuPretWrapper(demandePretImmo);
        simupretImmo.createProcessBuilder(simuPretExec.toString(), simuPretCWD.toFile());
        if (simupretImmo.startProcess() == 0)
            System.out.println(simupretImmo.parseJson(simuPretJSON.toFile(), SimuPretWrapperData.class).toString());

        // Troisieme demande de pret
        // Type de pret -> C
        // Capital -> 8000
        // Durée -> 3
        DemandePret demandePretConso = new DemandePret('C', new BigDecimal("8000"), 3);
        SimuPretWrapper simupretConso = new SimuPretWrapper(demandePretConso);
        simupretConso.createProcessBuilder(simuPretExec.toString(), simuPretCWD.toFile());
        if (simupretConso.startProcess() == 0)
            System.out.println(simupretConso.parseJson(simuPretJSON.toFile(), SimuPretWrapperData.class).toString());
    }
}
