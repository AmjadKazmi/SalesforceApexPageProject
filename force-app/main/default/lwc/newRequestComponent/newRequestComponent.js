import { api, LightningElement } from 'lwc';

export default class NewRequestComponent extends LightningElement {
    __modalVisible = false;

    @api
    get modalVisible() {
        return this.__modalVisible;
    }   
    set modalVisible(value) {
        this.__modalVisible = value;
        console.log('Modal visibility changed:', value);
    }

    closeModal() {
        
        this.dispatchEvent(
            new CustomEvent('closemodal')
        );
        console.log('Modal closed');
    }
  
}