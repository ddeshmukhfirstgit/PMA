import { LightningElement, track } from 'lwc';
import getAllProfilesWithPermissions from '@salesforce/apex/ProfileAnalyser.getAllProfilesWithPermissions';

export default class Profilelister extends LightningElement {
    @track profiles;
    @track profileOptions = [];        // combobox options
    @track selectedProfile;  
    @track isLoading = false;
    @track error = null;
    
    columns = [
        { label: 'Profile Name', fieldName: 'profileName', type: 'text', sortable: true },
        { label: 'Profile ID', fieldName: 'profileId', type: 'text' }
    ];
    
    connectedCallback() {
        console.log('Component initialized, loading profiles...');  
        this.loadProfiles();
    }
    
    loadProfiles() {
        this.isLoading = true;
        this.error = null;
        
        getAllProfilesWithPermissions()
            .then((result) => {
                console.log(result);
                this.profiles = result;
                // build combobox options from the returned array
                this.profileOptions = result.map(p => {
                    return {
                        label: p.profileName,
                        value: p.profileId
                    };
                });
                this.isLoading = false;
            })
            .catch((error) => {
                this.error = error.body?.message || 'Unknown error occurred';
                this.isLoading = false;
            });
    }

    handleProfileChange(event) {
        this.selectedProfile = event.detail.value;
        // do whatever you need with the selected profile id/name
    }
}