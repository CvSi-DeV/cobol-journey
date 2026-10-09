package nc.cvsi.simupret.exceptions;

public class SimuPretHttpServerException extends RuntimeException {
    public SimuPretHttpServerException(String sHSException) {
        super(sHSException);
    }

    public SimuPretHttpServerException(String message, Throwable cause) {
        super(message, cause);
    }
}
