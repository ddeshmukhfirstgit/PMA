public with sharing class ProfileAnalyser {
    /**
     * Retrieves all permissions for a given profile name
     * @param profileName The name of the profile
     * @return Map of permission names to boolean values
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Boolean> getProfilePermissions(String profileName) {
        Map<String, Boolean> permissions = new Map<String, Boolean>();
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        
        if (profile != null) {
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE ProfileId = :profile.Id LIMIT 1];
            permissions = getPermissionSetPermissions(ps.Id);
        }
        
        return permissions;
    }
    
    /**
     * Retrieves all permissions for a PermissionSet
     * @param permissionSetId The ID of the permission set
     * @return Map of permission names to boolean values
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Boolean> getPermissionSetPermissions(String permissionSetId) {
        Map<String, Boolean> permissions = new Map<String, Boolean>();
        
        List<ObjectPermissions> objectPerms = [
            SELECT SobjectType, PermissionsCreate, PermissionsRead, 
                   PermissionsEdit, PermissionsDelete
            FROM ObjectPermissions 
            WHERE ParentId = :permissionSetId
        ];
        
        for (ObjectPermissions op : objectPerms) {
            permissions.put(op.SobjectType + '_Create', op.PermissionsCreate);
            permissions.put(op.SobjectType + '_Read', op.PermissionsRead);
            permissions.put(op.SobjectType + '_Update', op.PermissionsEdit);
            permissions.put(op.SobjectType + '_Delete', op.PermissionsDelete);
        }
        
        return permissions;
    }
    
    /**
     * Retrieves all profiles with their enabled permissions
     * @return List of profiles with permission details
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getAllProfilesWithPermissions() {
        List<Map<String, Object>> profileList = new List<Map<String, Object>>();
        
        List<Profile> profiles = [SELECT Id, Name FROM Profile ORDER BY Name];
        
        for (Profile p : profiles) {
            Map<String, Object> profileData = new Map<String, Object>();
            profileData.put('profileName', p.Name);
            profileData.put('profileId', p.Id);
            //profileData.put('permissions', getProfilePermissions(p.Name));
            profileList.add(profileData);
        }
        
        return profileList;
    }
}