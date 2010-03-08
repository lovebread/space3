Iyxzone = {};

Object.extend(Iyxzone, {

  version: 1.0,

  author: ['高侠鸿'],

  // some utilities
  disableButton: function(button, text){
    button.writeAttribute({disabled: 'disabled'});
    this.background = button.style.background;
    button.setStyle({
      background: 'grey',
      opacity: 0.5
    });
    button.value = text;
  },

  enableButton: function(button, text){
    button.disabled = '';
    button.setStyle({
      background: this.background,
      opacity: 1
    });
    button.value = text;
  },

  validationCode: function(digits){
    var codes = new Array(digits);       //用于存储随机验证码
    var colors = new Array("Red","Green","Gray","Blue","Maroon","Aqua","Fuchsia","Lime","Olive","Silver");
    for(var i=0;i < codes.length;i++){//获取随机验证码
      codes[i] = Math.floor(Math.random()*10);
    }
    var div = new Element('div');
    for(var i = 0;i < codes.length;i++){
      var span = new Element('span');
      span.innerHTML = codes[i];
      span.setStyle({color: colors[Math.floor(Math.random()*10)]});
      div.appendChild(span);
    }
    return {codes: codes, div: div};
  },


});

Iyxzone.limitedTextField = Class.create({

  initialize: function(el, max, div){
    this.el = el;
    this.max = max;
    this.div = div;
    this.timer = null;
    this.firstFocus = true;
    this.interval = 200;
    
    this.el.observe('focus', function(){
      if(this.firstFocus){
        this.el.clear();
        if(this.div)
          this.div.innerHTML = '0/' + this.max;
        this.firstFocus = false;
      }
      this.timer = setTimeout(this.checkLength.bind(this), this.interval);
    }.bind(this));

    this.el.observe('blur', function(){
      clearTimeout(this.timer);
    }.bind(this));
  },

  checkLength: function(){
    var count = this.el.value.length;
    if(count > this.max){
      this.el.value = this.el.value.substr(0, this.max);
    }else{
      if(this.div)
        this.div.innerHTML = count + "/" + this.max;
    }
    this.timer = setTimeout(this.checkLength.bind(this), this.interval);
  }

});
