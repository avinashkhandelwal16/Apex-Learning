public class ContactTriggerHandler {
    public static void beforeInsert(List<Contact> contacts) {
        emailSentToContactCreation(contacts);
        //preventDuplicateContactBasedOnEmail(contacts);
        preventDuplicateContactBasedOnPhone(contacts);
    }

    public static void afterInsert(List<Contact> contacts) {
        //sendEmailOnContactCreation(contacts);
    }
    private static void emailSentToContactCreation(List<Contact> contacts) {
        List<Contact> conList = new List<Contact>();
        for(Contact contact : contacts) {
            conList.add(contact);
        }
        if(!conList.isEmpty()) {
            emailSentProcess();
        }
    }

    private static void emailSentProcess() {
        EmailTemplate templateId = [Select Id FROM EmailTemplate where Name = 'ContactEmail'];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'avinash.k@metadologie.com'}; 
        //String[] ccAddresses = new String[] {'avinashkhandelwal16@gmail.com'};
        mail.setToAddresses(toAddresses);
        //mail.setCcAddresses(ccAddresses); 
        mail.setSenderDisplayName('Salesforce Support');
        mail.setSubject('New Contact Created : ' + contact.Id);
        mail.setTemplateID(templateId.Id); 
        //mail.setTargetObjectId(contact.Id);
        //mail.setBccSender(false);
        //mail.setUseSignature(false);
        //mail.setPlainTextBody('Your Contact: ' + contact.Id +' has been created.');
        //mail.setHtmlBody('Your contact:<b> ' + contact.Id +' </b>has been created.<p>'+
          //  'To view your contact <a href=https://MyDomainName.my.salesforce.com/'+contact.Id+'>click here.</a>');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    private static void preventDuplicateContactBasedOnEmail(List<Contact> contacts) {
        Set<String> setEmail = new Set<String>();
        for(Contact contact : contacts) {
            setEmail.add(contact.Email);
        }
        List<Contact> contactList = [SELECT Id, Email FROM Contact WHERE Email IN : setEmail];
        for(Contact contact : contacts) {
            if(contactList.size() > 0) {
                contact.Email.AddError('Duplicate contact found, use diffrent email id');
            }
        }
    }

    private static void preventDuplicateContactBasedOnPhone(List<Contact> contacts) {
        Set<String> setPhone = new Set<String>();
        for(Contact contact : contacts) {
            setPhone.add(contact.phone);
        }
        List<Contact> conList = [SELECT Phone FROM Contact WHERE Phone IN : setPhone];
        for(Contact contact : contacts) {
            if(conList.size() > 0 && contact.phone != Null) {
                contact.phone.AddError('Duplicate contact found please change phone Number');
            }
        }
    }   

    private static void sendEmailOnContactCreation(List<Contact> contacts) {
        List<Contact> conList = new List<Contact>();
        for(Contact contact : contacts) {
            conList.add(contact);
        }
        if(!conList.isEmpty()) {
            sendEmailOnContactCreationBody();
        }
    }   

    private static void sendEmailOnContactCreationBody() {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'avinash.k@metadologie.com'};
        email.setToAddresses(toAddresses);
        email.setSubject('Welcome in salesforce');
        email.setSenderDisplayName('Salesforce Support');
        email.setHtmlBody('hi, contact have been created');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}