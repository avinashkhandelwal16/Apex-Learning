public class UserTriggerHandler { 
    public static void afterInsert(List<User> users) {
        createNewUser(users);
    }

    private static void createNewUser(List<User> users) {
        Group publicGroup = [SELECT Id, Name FROM Group WHERE DeveloperName = 'Admins'];
        Profile profileName = [SELECT ID FROM Profile WHERE Name = 'System Administrator'];
        List<GroupMember> groupMembers = new List<GroupMember>();
        for(User user : users) {
            if(user.profileId ==  profileName.Id && user.IsActive == true) {
                GroupMember groupMember = new GroupMember();
                groupMember.groupId = publicGroup.Id;
                groupMember.UserOrGroupId = user.Id;
                groupMembers.add(groupMember);
            }
        }
        if(!groupMembers.isEmpty()) {
            insert groupMembers;
        }
    }
}