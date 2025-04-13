import { LightningElement, api } from 'lwc';
import searchByObjectLabel from '@salesforce/apex/NewRequestService.searchByObjectLabel';

export default class SearchableCombox extends LightningElement {
    @api label;
    searchKey = '';
    options = [];
    showDropdown = false;
    positionDropdownBound;

    handleFocus() {
          requestAnimationFrame(() => {
             this.positionDropdown();
        });
        this.fetchData(this.label, this.searchKey);
        this.showDropdown = true;
    }
    
    positionDropdown() {
    const wrapper = this.refs?.searchWrapper;
    const dropdown = this.template.querySelector('.custom-dropdown-container-below');

    if (wrapper && dropdown) {
        const rect = wrapper.getBoundingClientRect();
            dropdown.style.left = `${rect.left + 15} px`;
            dropdown.style.top = `${rect.bottom}px`;
            dropdown.style.width = `${rect.width}px`;
        }
    }

    connectedCallback() {
    window.addEventListener('resize', this.positionDropdownBound = this.positionDropdown.bind(this));
    }

    disconnectedCallback() {
    window.removeEventListener('resize', this.positionDropdownBound);
    }

    handleBlur() {
       setTimeout(() => {
        this.showDropdown = false;
    }, 200); 
    }

    handleInputChange(event) {
        this.searchKey = event.target.value;
        console.log('search Key from HandleInputChange:', this.searchKey);
        this.fetchData(this.label, this.searchKey);
        this.showDropdown = true;
    }

    handleClick(event) {
          requestAnimationFrame(() => {
             this.positionDropdown();
        });
        this.searchKey = event.target.value;
        console.log('search Key from click:', this.searchKey);
        this.fetchData(this.label, this.searchKey);
        this.showDropdown = true;      
    }

    async fetchData(object, searchText) {
        console.log(object+''+searchText);
            switch (object) {
                case 'Account':
                    searchByObjectLabel({ objectLabel: 'Account', searchKey: searchText })
                        .then(result => {
                            this.options = result;
                        })
                        .catch(error => console.error('Error searching accounts:', error));
                    break;
                case 'Vehicle':
                    searchByObjectLabel({ objectLabel: 'Vehicle__c', searchKey: searchText })
                        .then(result => {
                            this.options = result;
                        })
                        .catch(error => console.error('Error searching vehicles:', error));
                    break;
                case 'Contact':
                            console.log('Search Key:', searchText);
                    console.log('Label:', this.label);
                    console.log('Contact options:', this.options);
                    searchByObjectLabel({ objectLabel: 'Contact', searchKey: searchText })
                        .then(result => {
                            this.options = result;
                            
                        })
                        .catch(error => console.error('Error searching contacts:', error));
                    break;
                default:
                    console.warn('Unsupported label:', label);
            }
    }
   
       

    handleSelect(event) { 
        console.log('Select event triggered');
        const selectedID= event.currentTarget.dataset.value;
        console.log('Selected value:', selectedID);
        const selectedValue = this.options.find(opt => opt.value === selectedID)?.label;
        this.searchKey = selectedValue;
        console.log('Selected value:', selectedValue);
        this.showDropdown = false;

        const selectEvent = new CustomEvent('selected', { detail: { label:this.label, ID:selectedID } });
        this.dispatchEvent(selectEvent);
    }

    get computedComboboxClass() {
        return `slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ${this.showDropdown ? 'slds-is-open' : ''}`;
    }

}