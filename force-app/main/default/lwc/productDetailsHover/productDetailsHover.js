import { LightningElement, api, wire } from 'lwc';

export default class ProductDetailsHover extends LightningElement {
    ishovered = false;
    __caseData;
    productData;
    @api caseId;
    productDetailForCaseId = [];
    formattedProductDetails = '';

    @api
    get caseData() {
        return this.__casedata;
    }
    set caseData(value) {
        this.__casedata = value;
        this.productData = this.__casedata;
    }

    connectedCallback() {
        console.log('Received Case ID:', this.caseId);
        // You can use this ID to fetch additional details if needed
    }

    handleMouseEnter(event) {
        this.productDetailForCaseId = this.caseData[this.caseId];
        if (this.productDetailForCaseId) {
            console.log('Product Details:', JSON.stringify(this.productDetailForCaseId));

            this.formattedProductDetails = Object.entries(this.productDetailForCaseId).map(([product, quantity]) => {
                return {
                    product,
                    quantity,
                    displayText: `${product}: ${quantity} units`
                };
            });
        }
            this.ishovered = true;
        
    }

    handleMouseLeave() {
        this.ishovered = false;
    }

    get productContent()
    {
        return 'Details\n'.this.productDetailForCaseId.join('\n');
    }
}
