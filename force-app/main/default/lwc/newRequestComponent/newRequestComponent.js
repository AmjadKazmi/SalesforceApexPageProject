import { api, LightningElement, track, wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import ORIGIN_FIELD from '@salesforce/schema/Case.Origin';
import REASON_FIELD from '@salesforce/schema/Case.Reason';
import PRIORITY_FIELD from '@salesforce/schema/Case.Priority';
import GETPRODUCTS from '@salesforce/apex/NewRequestService.getProducts';


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
    ProductOptions = [];
    selectedValue;
    selectedValues = {};

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
    }

    
    @wire(GETPRODUCTS)
    wireProducts({ error, data }) {
        if (data) {
            console.log('Products New Request Component:', JSON.stringify(data));
            this.ProductOptions = data.map(item => ({
                Name: item.Name,
                ID: item.Id
            }));
        } else if (error) {
            console.error('Error loading products:', JSON.stringify(error));
        }
        console.log('Product Options in New Request Component:', JSON.stringify(this.ProductOptions));
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
     * @description This method fetches the picklist values for the Reason field on the Case object.
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
        console.log('Selected values after Save:', JSON.stringify(this.selectedValues));
        this.dispatchEvent(new CustomEvent('closemodal'));
    }
}
