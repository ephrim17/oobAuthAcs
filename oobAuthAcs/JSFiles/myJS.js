var helloWorld = "Hello Javascript!"

var toggleRRN = rrn()

function rrn() {
    var ran1 = JSON.stringify(Math.floor(Math.random() * 8999999999999999999 + 1000000000000000000));
    var entry = ran1;
    var entryArray = [];
    var tst = "";
    var i;
    for (i = 0; i < entry.length; i++) {
        entryArray[i] = entry.charAt(i);
    }
    if (entryArray[0] % 2 == 0) {
        console.log("yes");
        var val = entryArray[3];
        var total = parseInt(val) + 8;
        for (i = val; i < total; i++) {
            tst = tst + (entryArray[(entryArray[i])]);
        }
    }
    else {
        console.log("no");
        var val = entryArray[6];
        var total = parseInt(val) + 8;
        for (i = val; i < total; i++) {
            tst = tst + (entryArray[(entryArray[i])]);
        }
    }
    
    var a =  ran1 + tst
    return a
}

var validateCard = function validateCreditCard(ccNum){
    
    var visaPattern = /^(?:4[0-9]{12}(?:[0-9]{3})?)$/;
    var mastPattern = /^(?:5[1-5][0-9]{14})$/;
    var amexPattern = /^(?:3[47][0-9]{13})$/;
    var discPattern = /^(?:6(?:011|5[0-9][0-9])[0-9]{12})$/;
    var ruPayPattern = /^6[0-9]{15}$/;
    
    var isVisa = visaPattern.test( ccNum ) === true;
    var isMast = mastPattern.test( ccNum ) === true;
    var isAmex = amexPattern.test( ccNum ) === true;
    var isDisc = discPattern.test( ccNum ) === true;
    var isRuapy = ruPayPattern.test( ccNum ) === true;
    
    if( isVisa || isMast || isAmex || isDisc || isRuapy ) {
        // at least one regex matches, so the card number is valid.
        
        if( isVisa ) {
            // Visa-specific logic goes here
            return "Visa"
        }
        else if( isMast ) {
            return "Master"
            // Mastercard-specific logic goes here
        }
        else if( isAmex ) {
            return "Amex"
            // AMEX-specific logic goes here
        }
        else if( isDisc ) {
            return "Rupay"
            // Discover-specific logic goes here
        }
        
        else if( isRuapy ) {
            return "Rupay"
            // Discover-specific logic goes here
        }
    }
    else {
        return "errorCard"
    }
}

var ValidateEmailMob = function validateEmail(sEmail) {
    //var reEmail = /^(?:\d{10}|\w+@\w+\.\w{2,3})$/;
    var reEmail = /^(?:\d[0-9]{6,14}|\w+@\w+\.\w{2,3})$/;
    
    //^((\\+)|(00))[0-9]{6,14}$
                        
    if(!sEmail.match(reEmail)) {
        
    return false;
    }
    return true;
}

