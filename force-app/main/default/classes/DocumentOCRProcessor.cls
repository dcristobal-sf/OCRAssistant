global class DocumentOCRProcessor {

    private final static string RESULTADO = 'result';
    private final static string POSITIVO = 'positiv';
    private final static string NEGATIVO = 'negativ';
    private final static string PCR = 'pcr';
    private final static string ANTIGENO = 'antigen';
    private final static string VACUNA = 'vacuna';
    private final static string NA = 'N/A';
    
    public DocumentOCRProcessor() {

    }

    global class DocumentResult {
        @InvocableVariable
        global string resultType;

        @InvocableVariable
        global string resultText;
    }
}
