let moonPay;
let currentMoonPaySdk; // Store current SDK instance for handlers

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
        'production': 'pk_live_ITSKGCf8pIJnaiQme4AAQ6NbqdRQt0c'
    }

    const SIGNATURE_SERVICE_BASE_URLS = {
        'sandbox': 'https://data-testnet.verifiedx.io',
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
            currencyCode: baseCurrencyCode,
            baseCurrencyCode: "usd",
            baseCurrencyAmount: baseCurrencyAmount,
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
            walletAddress: walletAddress,

        }

        const moonPaySdk = moonPay({
            flow: 'sell',
            environment: environment,
            variant: 'overlay',
            params: params,
            handlers: {
                async onInitiateDeposit(properties) {
                    console.log("onInitiateDeposit called", properties)
                    const {
                        cryptoCurrency,
                        cryptoCurrencyAmount,
                        depositWalletAddress,
                    } = properties;

                    // Extract currency code from object
                    const currencyCode = typeof cryptoCurrency === 'string'
                        ? cryptoCurrency
                        : (cryptoCurrency?.code || 'btc');

                    // Try to close the modal
                    try {
                        if (currentMoonPaySdk?.hide) {
                            currentMoonPaySdk.hide();
                        } else if (currentMoonPaySdk?.close) {
                            currentMoonPaySdk.close();
                        }
                    } catch (e) {
                        console.log("Could not close MoonPay modal", e);
                    }

                    // Wait for Flutter to complete the send
                    return new Promise((resolve, reject) => {
                        // Call Flutter callback with deposit details and callbacks
                        console.log("Checking for Flutter callback...");
                        console.log("window.flutterMoonPayDepositCallback exists:", !!window.flutterMoonPayDepositCallback);

                        if (window.flutterMoonPayDepositCallback) {
                            console.log("Calling Flutter callback with:", {
                                currencyCode,
                                cryptoCurrencyAmount,
                                depositWalletAddress
                            });

                            try {
                                window.flutterMoonPayDepositCallback(
                                    currencyCode,
                                    cryptoCurrencyAmount,
                                    depositWalletAddress,
                                    (txHash) => {
                                        console.log("Flutter callback resolved with txHash:", txHash);
                                        resolve({ depositId: txHash });
                                    },
                                    (error) => {
                                        console.error("Flutter callback rejected with error:", error);
                                        reject(error);
                                    }
                                );
                                console.log("Flutter callback invoked successfully");
                            } catch (e) {
                                console.error("Exception calling Flutter callback:", e);
                                reject(e);
                            }
                        } else {
                            console.error("Flutter callback not registered on window");
                            console.log("Available window properties:", Object.keys(window).filter(k => k.includes('flutter')));
                            reject(new Error("Flutter callback not registered"));
                        }
                    });
                }
            }
        });

        // Store SDK instance for handler access
        currentMoonPaySdk = moonPaySdk;

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