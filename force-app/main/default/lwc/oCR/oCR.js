import { LightningElement, track, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import performOCR from '@salesforce/apex/OCRController.performOCR';

export default class OCR extends LightningElement {
    @api url;
    @track results;
    @track error;

    handleClick() {
        performOCR({
                url: this.url
            })
            .then(() => {
                return refreshApex(this.results);
            })
            .catch(error => {
                this.error = error.body.message;
        });
    }
}