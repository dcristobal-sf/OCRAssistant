/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import libraries from '@salesforce/resourceUrl/libraries';
import performOCR from '@salesforce/apex/OCRController.performOCR';

export default class OCR extends LightningElement {
    @track url;
    @track results;
    @track error;

    renderedCallback() {
        Promise.all([
            loadScript(this, libraries + '/jquery-3.4.1.min.js'),
            loadScript(this, libraries + '/popper.min.js'),
            loadScript(this, libraries + '/bootstrap.min.js')
        ]).then(() => { this.scriptsLoaded(); });
    }

    scriptsLoaded() {
        var context = $("canvas").getContext("2d");
        console.log(context);
    }

    handleChange(event) {
        this.url = event.target.value;
    }

    handleClick() {
        performOCR({url: this.url})
            .then(result => {
                this.results = result;
            })
            .catch(error => {
                this.error = error.body.message;
        });
    }
}