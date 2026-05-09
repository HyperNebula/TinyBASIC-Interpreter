const originalConsoleLog = console.log;
console.log = function (...args) {
    const message = args.map((arg) => String(arg)).join(" ");
    postMessage({ type: 'output', text: message });
    originalConsoleLog.apply(console, args);
};

importScripts('tinybasic.js');

self.onmessage = function (e) {
    if (e.data.type === 'run') {
        try {
            if (typeof loadInputs === 'function') {
                loadInputs(e.data.inputs || "");
            }
            
            runBasic(e.data.code);
            postMessage({ type: 'complete' });
        } catch (error) {
            postMessage({ type: 'error', text: error.toString() });
        }
    }
};