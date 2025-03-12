

let moonPay;


var scriptLoadingStatus = {
    isLoading: false,
    isLoaded: false
};
async function loadMoonPay(version = "v1") {
    return new Promise((resolve, reject) => {
        const scriptSrc = `https://static.moonpay.com/web-sdk/${version}/moonpay-web-sdk.min.js`;
        const existingScript = document.querySelector(`script[src="${scriptSrc}"]`);
        scriptLoadingStatus.isLoading = true;
        const checkLoaded = (count = 0) => {
            if (window.MoonPayWebSdk) {
                scriptLoadingStatus.isLoading = false;
                scriptLoadingStatus.isLoaded = true;
                resolve(window.MoonPayWebSdk.init);
                return;
            }
            if (count > 100) {
                scriptLoadingStatus.isLoading = false;
                reject(new Error("Loading MoonPayWebSdk script timed out."));
                return;
            }
            setTimeout(() => checkLoaded(count + 1), 100);
        };
        if (existingScript) {
            checkLoaded();
        } else {
            const script = document.createElement("script");
            script.async = true;
            script.src = scriptSrc;
            script.addEventListener("load", () => {
                scriptLoadingStatus.isLoading = false;
                scriptLoadingStatus.isLoaded = true;
                resolve(window.MoonPayWebSdk?.init);
            });
            script.addEventListener("error", () => {
                scriptLoadingStatus.isLoading = false;
                scriptLoadingStatus.isLoaded = false;
                reject(new Error("Failed to load MoonPayWebSdk script."));
            });
            document.body.appendChild(script);
        }
    });
}


const initMoonPay = async () => {


    moonPay = await loadMoonPay();

    const PUBLIC_KEYS = {
        'sandbox': 'pk_test_jV5Sx41ah71d30jfIoXvWq3QLlPBilV',
        'production': 'pk_live_w80iBmizF5yrhtqpwxyPNG6e4jhTw9BS'
    }

    const SIGNATURE_SERVICE_BASE_URLS = {
        'sandbox': 'http://localhost:8000',
        'production': 'https://data.verifiedx.io'
    }


    window.moonPayBuy = async (environment, baseCurrencyCode, baseCurrencyAmount, walletAddress, popup) => {

        if (!['sandbox', 'production'].includes(environment)) {
            console.log("Moonpay: invalid environment")
            return;
        }

        const params = {
            apiKey: PUBLIC_KEYS[environment],
            theme: 'dark',
            baseCurrencyCode: baseCurrencyCode,
            baseCurrencyAmount: baseCurrencyAmount,
            defaultCurrencyCode: baseCurrencyCode,
            walletAddress: walletAddress
        }

        const moonPaySdk = moonPay({
            flow: 'buy',
            environment: environment,
            variant: 'overlay',
            params: params
        });

        const urlForSignature = moonPaySdk.generateUrlForSigning();


        const signatureResponse = await fetch(`${SIGNATURE_SERVICE_BASE_URLS[environment]}/payment/sign-url-for-moonpay/`, {
            method: 'POST',
            body: JSON.stringify({ 'url_for_signature': urlForSignature })
        });

        const signatureResult = await signatureResponse.json();

        if (!signatureResult.success) {
            window.open(urlForSignature);
            return;
        }

        moonPaySdk.updateSignature(signatureResult.signature);

        if (popup) {
            moonPaySdk.show();

        } else {
            window.open(signatureResult.url);

        }


    }

    window.moonPaySell = async (environment, baseCurrencyCode, baseCurrencyAmount, walletAddress, popup) => {

        if (!['sandbox', 'production'].includes(environment)) {
            console.log("Moonpay: invalid environment")
            return;
        }

        const params = {
            apiKey: PUBLIC_KEYS[environment],
            theme: 'dark',
            baseCurrencyCode: baseCurrencyCode,
            baseCurrencyAmount: baseCurrencyAmount,
            defaultCurrencyCode: baseCurrencyCode,
            walletAddress: walletAddress
        }

        const moonPaySdk = moonPay({
            flow: 'sell',
            environment: environment,
            variant: 'overlay',
            params: params
        });

        const urlForSignature = moonPaySdk.generateUrlForSigning();


        const signatureResponse = await fetch(`${SIGNATURE_SERVICE_BASE_URLS[environment]}/payment/sign-url-for-moonpay/`, {
            method: 'POST',
            body: JSON.stringify({ 'url_for_signature': urlForSignature })
        });

        const signatureResult = await signatureResponse.json();

        if (!signatureResult.success) {
            window.open(urlForSignature);
            return;
        }

        moonPaySdk.updateSignature(signatureResult.signature);

        if (popup) {
            moonPaySdk.show();

        } else {
            window.open(signatureResult.url);

        }


    }

}




initMoonPay();