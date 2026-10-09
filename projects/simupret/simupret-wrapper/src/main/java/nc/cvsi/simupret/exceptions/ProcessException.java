package nc.cvsi.simupret.exceptions;

public class ProcessException extends RuntimeException {
    public ProcessException(String pException) {
        super(pException);
    }

    public ProcessException(String pException, Throwable cause) {
        super(pException, cause);
    }

}
