import { api, LightningElement, track, wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import ORIGIN_FIELD from '@salesforce/schema/Case.Origin';
import REASON_FIELD from '@salesforce/schema/Case.Reason';
import PRIORITY_FIELD from '@salesforce/schema/Case.Priority';
import TYPE_FIELD from '@salesforce/schema/Case.Type';
import GETPRODUCTS from '@salesforce/apex/NewRequestService.getProducts';
import INSERTRECORD from '@salesforce/apex/InsertRecords.InsertCaseRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { MessageContext, publish } from 'lightning/messageService';  
import CASE_CREATED_CHANNEL from '@salesforce/messageChannel/CaseCreatedChannel__c';



/**
 * @author Amjad Ali
 */
export default class NewRequestComponent extends LightningElement {
    __modalVisible = false;

    contactOptions = [];
    accountOptions = [];
    vehicleOptions = [];
    originOptions = [];
    statusOptions = [];
    reasonOptions = [];
    priorityOptions = [];
    typeOptions = [];
    ProductOptions = [];
    selectedValue;
    selectedValues = {
        CaseOrigin: '',
        Status: '',
        Reason: '',
        Priority: '',
        Type: ''
    };

    @wire(MessageContext) messageContext;

    @api
    get modalVisible() {
        return this.__modalVisible;
    }
    set modalVisible(value) {
        this.__modalVisible = value;
    }

    closeModal() {
        document.body.style.overflow = '';
        this.dispatchEvent(new CustomEvent('closemodal'));
        removedSelectedValue();
    }

    
    @wire(GETPRODUCTS)
    wireProducts({ error, data }) {
        if (data) {
            this.ProductOptions = data.map(item => ({
                label: item.Name,
                value: item.Id
            }));
        } else if (error) {
            console.error('Error loading products:', JSON.stringify(error));
        }
    }
    
    /**
     *  @description This method handles the selected values (contact, account and vechile) 
     * coming from child component.
     * @param {@} event 
     */
    handleSelectedValue(event) {
        const selectedID = event.detail.ID;
        const selectedLabel = event.detail.label;
        this.selectedValues[selectedLabel] = selectedID;
    }
    

    /**
     * @description This method fetches the picklist values for the Case object.
     * @param {object} param0 - The object containing the data and error properties.
     * @param {object} param0.data - The data returned from the server.
     * @date 2025-04-10
     */

/**************************************************************************************************/

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    caseMetadata;

    @wire(getPicklistValues, { recordTypeId: '$caseMetadata.data.defaultRecordTypeId', fieldApiName: ORIGIN_FIELD })
    wiredOrigin({ data, error }) {
        if (data) {
            this.originOptions = data.values.map(val => ({ label: val.label, value: val.value }));
        } else if (error) {
            console.error('Error loading origin picklist:', error);
        }
    }
    
    @wire(getPicklistValues, { recordTypeId: '$caseMetadata.data.defaultRecordTypeId', fieldApiName: STATUS_FIELD })
    wiredStatus({ data, error }) {
        if (data) {
            this.statusOptions = data.values.map(val => ({ label: val.label, value: val.value }));
        } else if (error) {
            console.error('Error loading status picklist:', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$caseMetadata.data.defaultRecordTypeId', fieldApiName: REASON_FIELD })
    wiredReason({ data, error }) {
        if (data) {
            this.reasonOptions = data.values.map(val => ({ label: val.label, value: val.value }));
        } else if (error) {
            console.error('Error loading reason picklist:', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$caseMetadata.data.defaultRecordTypeId', fieldApiName: PRIORITY_FIELD })
    wiredPriority({ data, error }) {
        if (data) {
            this.priorityOptions = data.values.map(val => ({ label: val.label, value: val.value }));
        } else if (error) {
            console.error('Error loading priority picklist:', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$caseMetadata.data.defaultRecordTypeId', fieldApiName: TYPE_FIELD })
    wiredType({ data, error }) {
        if (data) {
            this.typeOptions = data.values.map(val => ({ label: val.label, value: val.value }));
        } else if (error) {
            console.error('Error loading Case Type picklist:', error);
        }
    }
/****************************************************************************************************/

    /**
     * @description This method handles the selected values from the combo box.
     * @param {*} event 
     */
    handleSelectedValueComboBox(event) {
        this.selectedValue = event.detail.value;
        const label =  event.target.getAttribute('data-label');
        this.selectedValues[label] = this.selectedValue;
    }
    


    handleSave() {
        const selectedValues = {
            ...this.selectedValues,
            fields: this.fields
        };
        this.dispatchEvent(new CustomEvent('closemodal'));
        INSERTRECORD({ caseDataJson: JSON.stringify(selectedValues) })
            .then(result => {
                if (result && result.CaseNumber) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: `Case created successfully with Case Number: ${result.CaseNumber}`,
                            variant: 'success'
                        })
                    );
                    // Reset form values after successful save
                    this.removedSelectedValue();
                    // Publish message to notify other components
                    const payload = {       
                        caseId: result.Id
                    };
                    publish(this.messageContext, CASE_CREATED_CHANNEL, payload);
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Case creation failed. No Case Number returned.',
                            variant: 'error'
                        })
                    );
                    this.removedSelectedValue();
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: `Error inserting record: ${error.body.message}`,
                        variant: 'error'
                    })
                );
                this.removedSelectedValue();
                console.error('Error inserting record:', error);
            });
    }

    
    removedSelectedValue() {
        this.selectedValues = {
            CaseOrigin: '',
            Status: '',
            Reason: '',
            Priority: '',
            Type: ''
            };
        this.fields = [];
    }
        


    /** Logic to add multiple part along with Meantaince request */
    /************************************************************************** */
    fields = [];

    addField() {
        this.fields = [...this.fields, { id: Date.now(), productDescription: '', productID: '' }];
    }

    handleTextChange(event) {
        const index = event.target.dataset.index;
        this.fields[index].text = event.target.value;
    }

    handleDropdownChange(event) {
        const index = event.target.dataset.index;
        this.fields[index].productID = event.target.value;
    }

    removeField(event) {
        const index = event.target.dataset.index;
        this.fields.splice(index, 1);
        this.fields = [...this.fields]; // trigger reactivity
    }
}