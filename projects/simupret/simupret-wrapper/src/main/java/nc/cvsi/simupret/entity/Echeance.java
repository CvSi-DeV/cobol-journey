package nc.cvsi.simupret.entity;

import java.math.BigDecimal;

import com.fasterxml.jackson.annotation.JsonAlias;

public class Echeance {
    @JsonAlias("NUM-ECHEANCE")
    private int numEcheance;
    @JsonAlias("CAPITAL-PREC")
    private BigDecimal capitalPrecedent;
    @JsonAlias("INTERET-ECHEANCE")
    private BigDecimal interetEcheance;
    @JsonAlias("CAPITAL-REMBOURSE")
    private BigDecimal capitalRembourse;
    @JsonAlias("CAPITAL-RESTANT")
    private BigDecimal capitalRestant;

    public Echeance() {
    }

    public int getNumEcheance() {
        return numEcheance;
    }

    public BigDecimal getCapitalPrecedent() {
        return capitalPrecedent;
    }

    public BigDecimal getCapitalRembourse() {
        return capitalRembourse;
    }

    public BigDecimal getCapitalRestant() {
        return capitalRestant;
    }

    public BigDecimal getInteretEcheance() {
        return interetEcheance;
    }

    public void setNumEcheance(int numEcheance) {
        this.numEcheance = numEcheance;
    }

    public void setCapitalPrecedent(BigDecimal capitalPrecedent) {
        this.capitalPrecedent = capitalPrecedent;
    }

    public void setCapitalRembourse(BigDecimal capitalRembourse) {
        this.capitalRembourse = capitalRembourse;
    }

    public void setCapitalRestant(BigDecimal capitalRestant) {
        this.capitalRestant = capitalRestant;
    }

    public void setInteretEcheance(BigDecimal interetEcheance) {
        this.interetEcheance = interetEcheance;
    }

    @Override
    public String toString() {
        String toString = new String("ECHEANCE: \n  -Numéro Echéance: " + this.numEcheance + "\n   -Capital Précédent: "
                + this.capitalPrecedent + "\n -Intérêt Echéance: " + this.interetEcheance + "\n  -Capital Remboursé:"
                + this.capitalRembourse + "\n  -Capital Restant: " + this.capitalRestant);
        return toString;
    }
}
