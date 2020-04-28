/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
import performOCRFromUpload from '@salesforce/apex/OCRController.performOCRFromUpload';
import Id from '@salesforce/user/Id';

let canvas;
let context;
export default class OCR extends LightningElement {
    @track imageBase64;
    @track imageType;
    @track ocrResult;

    @track error;
    userId = Id;

    get acceptedFormats() {
        return ['.jpg', '.png'];
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        uploadedFiles.forEach(p => {
            var name = p.name;
            var documentId = p.documentId;

            performOCRFromUpload({name: name, documentId: documentId})
            .then(result => {
                
                this.ocrResult = result.result;
                this.imageBase64 = result.imageBase64;
                this.imageType = result.imageType;

                this.renderImage();
                setTimeout(() => {  

                    let data = JSON.parse(this.ocrResult);
                    for (let i = 0; i < data.probabilities.length; i++) {
                        let boxData = data.probabilities[i];
                        context.beginPath();              
                        context.lineWidth = "2";
                        context.strokeStyle = "yellow";
                        context.rect(boxData.boundingBox.minX, boxData.boundingBox.minY, boxData.boundingBox.maxX - boxData.boundingBox.minX, boxData.boundingBox.maxY - boxData.boundingBox.minY);
                        context.stroke();
                    }

                }, 200);
            })
            .catch(error => {
                this.error = error.body.message;
            });

        });
    }

    renderedCallback() {
        canvas = this.template.querySelector('canvas');
        context = canvas.getContext("2d");
    }

    renderImage() {
        // Image is proxy to load the canvas for preview
        let img1 = new Image();

        context.clearRect(0, 0, canvas.width, canvas.height);

        img1.src = 'data:image/' + this.imageType + ';base64, ' + this.imageBase64;

        //drawing of the test image - img1
        img1.onload = function () {
            canvas.width = img1.width;
            canvas.height = img1.height;
            context.drawImage(img1, 0, 0, img1.width, img1.height);
        }; 
    }
}