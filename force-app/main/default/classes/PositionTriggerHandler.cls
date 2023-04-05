public class PositionTriggerHandler {
    public static void insertNewPosition(List<Position__c> posList) {
        for(Position__c position : posList) {
            if(position.Open_Date__c == null) {
                position.Open_Date__c = System.today();
            }        
            if(position.Max_Pay__c == null) {
                position.Max_Pay__c = 15000;
            }
            if(position.Min_Pay__c == null) {
                position.Min_Pay__c = 10000;
            }	           	 
        }
    }
}