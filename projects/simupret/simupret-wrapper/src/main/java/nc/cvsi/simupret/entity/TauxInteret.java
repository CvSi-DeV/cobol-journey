package nc.cvsi.simupret.entity;

import java.math.BigDecimal;

import com.fasterxml.jackson.annotation.JsonAlias;

public class TauxInteret {
    @JsonAlias("TAUX-ANNUEL")
    private BigDecimal tauxAnnuel;
    @JsonAlias("TAUX-MENSUEL")
    private BigDecimal tauxMensuel;

    public TauxInteret(BigDecimal tauxAnnuel, BigDecimal tauxMensuel) {
        setTauxAnnuel(tauxAnnuel);
        setTauxMensuel(tauxMensuel);
    }

    public TauxInteret() {
    }

    public void setTauxAnnuel(BigDecimal tauxAnnuel) {
        if (tauxAnnuel == null || tauxAnnuel.compareTo(BigDecimal.ZERO) <= 0)
            throw new RuntimeException("Le Taux annuel est invalide");
        this.tauxAnnuel = tauxAnnuel;
    }

    public BigDecimal getTauxAnnuel() {
        return this.tauxAnnuel;
    }

    public void setTauxMensuel(BigDecimal tauxMensuel) {
        if (tauxMensuel == null || tauxMensuel.compareTo(BigDecimal.ZERO) <= 0)
            throw new RuntimeException("Le Taux mensuel est invalide");
        this.tauxMensuel = tauxMensuel;
    }

    public BigDecimal getTauxMensuel() {
        return this.tauxMensuel;
    }

    @Override
    public String toString() {
        String toString = new String(
                "TAUX INTERET: \n  -TAUX ANNUEL: " + this.tauxAnnuel + "\n  -TAUX MENSUEL: " + this.tauxMensuel + "\n");
        return toString;
    }

    @Override
    public boolean equals(Object obj) {
        return super.equals(obj);
    }
}
