/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import libraries from '@salesforce/resourceUrl/libraries';
import performOCR from '@salesforce/apex/OCRController.performOCR';

let canvas;
let context;
export default class OCR extends LightningElement {
    @track url;
    @track results;
    @track error;

    renderedCallback() {
        /*
        Promise.all([
            loadScript(this, libraries + '/jquery-3.4.1.min.js'),
            loadScript(this, libraries + '/popper.min.js'),
            loadScript(this, libraries + '/bootstrap.min.js')
        ]).then(() => { this.scriptsLoaded(); });
*/
console.log('renderedCallback');
            loadScript(this, libraries + '/jquery-3.4.1.min.js');
            loadScript(this, libraries + '/popper.min.js');
            loadScript(this, libraries + '/bootstrap.min.js');
         this.scriptsLoaded(); 
    }

    scriptsLoaded() {

        console.log('scriptsLoaded');
        
        canvas = this.template.querySelector('canvas');
        context = canvas.getContext("2d");
        console.log(canvas);
        console.log(context);
        //var context = $("canvas").getContext("2d");
        //console.log(context);
    }


   



     log(x) { console.log(x); }


    handleChange(event) {
        this.url = event.target.value;
        let img1 = new Image();

        context.clearRect(0, 0, canvas.width, canvas.height);
        //drawing of the test image - img1
        img1.onload = function () {
            //draw background image
            context.drawImage(img1, 0, 0);
            //draw a box over the top
        
        };

        img1.src = event.target.value;

/*
        this.delayTimeout = setTimeout(() => {
                canvas.width=img1.width;
        canvas.height=img1.height;
        }, 100);

        */
    }

    handleClick() {
        performOCR({url: this.url})
            .then(result => {
                this.results = result;
                console.log('handleClick>>AnnotateCanvas');
               
                
                console.log(result);
                let data = JSON.parse(result);
                for (let i = 0; i < data.probabilities.length; i++) {
                    let boxData = data.probabilities[i];
                    //console.log(boxData);
                    context.beginPath();
                    //context.fillStyle = "rgba(255, 255, 0, 0.5)";               
                    context.lineWidth = "4";
                    context.strokeStyle = "yellow";
                    context.rect(boxData.boundingBox.minX, boxData.boundingBox.minY, boxData.boundingBox.maxX - boxData.boundingBox.minX, boxData.boundingBox.maxY - boxData.boundingBox.minY);
                    context.stroke();
                }
        
                
                //console.log(result);
            })
            .catch(error => {
                this.error = error.body.message;
        });
    }
}