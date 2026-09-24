package nc.cvsi.simupret.entity;

import java.math.BigDecimal;

import com.fasterxml.jackson.annotation.JsonAlias;

import nc.cvsi.simupret.exceptions.CapitalException;
import nc.cvsi.simupret.exceptions.DureeException;
import nc.cvsi.simupret.exceptions.TypePretException;

public class DemandePret {
    @JsonAlias("TYPE-PRET")
    private char typePret;
    @JsonAlias("CAPITAL")
    private BigDecimal capital;
    @JsonAlias("DUREE-PRET-ANNEE")
    private int duree;

    public DemandePret() {
    }

    public DemandePret(char typePret, BigDecimal capital, int duree) {
        setTypePret(typePret);
        setCapital(capital);
        setDuree(duree);
    }

    public char getTypePret() {
        return this.typePret;
    }

    public void setTypePret(char typePret) {
        if (typePret != 'A' && typePret != 'C' && typePret != 'I')
            throw new TypePretException("Le type de pret est invalide");
        this.typePret = typePret;

    }

    public BigDecimal getCapital() {
        return this.capital;
    }

    public void setCapital(BigDecimal capital) {
        if (capital == null || capital.compareTo(BigDecimal.ZERO) <= 0)
            throw new CapitalException("Le capital est invalide");
        this.capital = capital;
    }

    public int getDuree() {
        return this.duree;
    }

    public void setDuree(int duree) {
        if (duree <= 0)
            throw new DureeException("La durée du pret est invalide.");
        this.duree = duree;
    }

    @Override
    public String toString() {
        String toString = new String("Demande de PRET:\n  -Type Pret: " + this.typePret + "\n  -Capital: "
                + this.capital.toString() + "\n  -Durée Pret: " + this.duree + "\n");
        return toString;
    }

}
