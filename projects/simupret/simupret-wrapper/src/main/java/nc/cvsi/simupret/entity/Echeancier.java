package nc.cvsi.simupret.entity;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonAlias;

public class Echeancier {
    @JsonAlias("NB-ECHEANCES")
    private int nbEcheances;
    @JsonAlias("ECHEANCES")
    List<Echeance> echeances;

    public Echeancier() {

    }

    public List<Echeance> getEcheances() {
        return echeances;
    }

    public int getNbEcheances() {
        return nbEcheances;
    }

    public void setEcheances(List<Echeance> echeances) {
        this.echeances = echeances;
    }

    public void setNbEcheances(int numEcheance) {
        this.nbEcheances = numEcheance;
    }

    @Override
    public String toString() {
        String toString = new String("ECHEANCIER: \n  -Nombre Echéance: " + this.nbEcheances + "\n  -ECHEANCES:");
        for (Echeance echeance : echeances) {
            toString = toString + "\n    -Numero Echéance: " + echeance.getNumEcheance() + "\n    -Capital Précédent: "
                    + echeance.getCapitalPrecedent() + "\n    -Intérêt Echéance: " + echeance.getInteretEcheance()
                    + "\n    -Capital Remboursé: " + echeance.getCapitalRembourse() + "\n    -Capital Restant: "
                    + echeance.getCapitalRestant();
        }
        return toString;
    }
}