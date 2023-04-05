public class EmailSentClass {
    public static void EmailSentToContact(){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'avinash.k@metadologie.com'}; 
        String[] ccAddresses = new String[] {'avinashkhandelwal16@gmail.com'};
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);
        mail.setSenderDisplayName('Salesforce Support');
        mail.setSubject('New Contact Created : ' + contact.Id);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody('Your Contact: ' + contact.Id +' has been created.');
        mail.setHtmlBody('Your contact:<b> ' + contact.Id +' </b>has been created.<p>'+
            'To view your contact <a href=https://MyDomainName.my.salesforce.com/'+contact.Id+'>click here.</a>');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}