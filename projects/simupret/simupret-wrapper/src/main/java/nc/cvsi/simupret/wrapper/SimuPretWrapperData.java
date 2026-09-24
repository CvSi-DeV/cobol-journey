package nc.cvsi.simupret.wrapper;

import java.math.BigDecimal;

import com.fasterxml.jackson.annotation.JsonAlias;

import nc.cvsi.simupret.entity.DemandePret;
import nc.cvsi.simupret.entity.Echeancier;
import nc.cvsi.simupret.entity.TauxInteret;

public class SimuPretWrapperData {
    @JsonAlias("DEMANDE-PRET")
    private DemandePret demandePret;
    @JsonAlias("TAUX-INTERET")
    private TauxInteret tauxInteret;
    @JsonAlias("MENSUALITE")
    private BigDecimal mensualite;
    @JsonAlias("ECHEANCIER")
    private Echeancier echeancier;

    public SimuPretWrapperData() {
    }

    public DemandePret getDemandePret() {
        return demandePret;
    }

    public Echeancier getEcheancier() {
        return echeancier;
    }

    public BigDecimal getMensualite() {
        return mensualite;
    }

    public TauxInteret getTauxInteret() {
        return tauxInteret;
    }

    public void setDemandePret(DemandePret demandePret) {
        this.demandePret = demandePret;
    }

    public void setEcheancier(Echeancier echeancier) {
        this.echeancier = echeancier;
    }

    public void setMensualite(BigDecimal mensualite) {
        this.mensualite = mensualite;
    }

    public void setTauxInteret(TauxInteret tauxInteret) {
        this.tauxInteret = tauxInteret;
    }

    @Override
    public String toString() {
        String toString = this.demandePret.toString() + " " + this.tauxInteret.toString() + " "
                + "MENSUALITE: " + this.mensualite.toString() + " \n" + this.echeancier.toString();
        return toString;
    }

}
