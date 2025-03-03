import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getCaseCount from '@salesforce/apex/TicketController.getCaseCount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CaseCountTable extends LightningElement {
   wiredCaseData //to store the data for refreshApex
    tableData = [];
    
    // Define columns for data table
    columns = [
        {
            label: 'Type',
            fieldName: 'type',
            alignment: 'center',
            type: 'text',
            cellAttributes: {
                alignment: 'center'
            },
            hideDefaultActions: 'true'
        },
        { 
            label: 'Count', 
            fieldName: 'count', 
            type: 'number', 
            alignment: 'center',
            hideDefaultActions: 'true',
            cellAttributes: { 
                alignment: 'center', 
                class: { fieldName: 'colorClass' } // Dynamic color styling
            } 
        }
    ];
    
    /**
     * to get the case count from the server side controller and display it in the table
     * @param {*} result 
     * @author: Amjad Ali
     * @date: 2025-03-04     */
    @wire(getCaseCount)
    wiredCaseCount(result) {
        console.log('wireCaseCount is called');
        this.wiredCaseData = result;
        const { error, data } = result;
        if (data) {
           // Store the data for refreshApex
            this.tableData = Object.keys(data).map(status => ({
                type: status,
                count: data[status], // Accessing value from the map
                colorClass: this.colorMapping[status] || 'slds-text-color_default'
            }));
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error loading case count',
                    variant: 'error'
                })
            );
        }
    }
      
    // Define color mapping for case status
     colorMapping = {
        New: 'slds-text-color_default',        
        Working: 'slds-text-color_warning',  
        Escalated: 'slds-text-color_error', 
        Closed: 'slds-text-color_success'   
     };
    
    // Handle case update event
     handleCaseUpdate(event) {
        if (event.detail.updated) {
            console.log('Data updated, refreshing component...');
            refreshApex(this.wiredCaseData);  // Refresh data from Apex
        }
    }
}
