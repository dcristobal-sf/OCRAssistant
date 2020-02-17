/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
//import { refreshApex } from '@salesforce/apex'; refreshApex can only be used with @wire, which can't be used via button press. Not sure on the usecase exactly here, but I don't think we'll need it.
import performOCR from '@salesforce/apex/OCRController.performOCR';

export default class OCR extends LightningElement {
    @api url;
    @track results;
    @track error;

    handleClick() {
        console.log(this.url);
        performOCR({url: this.url})
            .then(result => {
                this.results = result;
            })
            .catch(error => {
                this.error = error.body.message;
        });
    }
}