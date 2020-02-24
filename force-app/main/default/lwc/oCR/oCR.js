/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
import performOCR from '@salesforce/apex/OCRController.performOCR';

let canvas;
let context;
export default class OCR extends LightningElement {
    @track url;
    @track results;
    @track error;

    renderedCallback() {
        canvas = this.template.querySelector('canvas');
        context = canvas.getContext("2d");
    }

    handleChange(event) {
        this.url = event.target.value;
        // Image is proxy to load the canvas for preview
        let img1 = new Image();

        context.clearRect(0, 0, canvas.width, canvas.height);

        img1.src = event.target.value;

        //drawing of the test image - img1
        img1.onload = function () {
            canvas.width = img1.width;
            canvas.height = img1.height;
            context.drawImage(img1, 0, 0, img1.width, img1.height);
        };

        
    }

    handleClick() {
        performOCR({url: this.url})
            .then(result => {
                this.results = result;
                let data = JSON.parse(result);
                for (let i = 0; i < data.probabilities.length; i++) {
                    let boxData = data.probabilities[i];
                    context.beginPath();              
                    context.lineWidth = "4";
                    context.strokeStyle = "yellow";
                    context.rect(boxData.boundingBox.minX, boxData.boundingBox.minY, boxData.boundingBox.maxX - boxData.boundingBox.minX, boxData.boundingBox.maxY - boxData.boundingBox.minY);
                    context.stroke();
                }
            })
            .catch(error => {
                this.error = error.body.message;
        });
    }
}