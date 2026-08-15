/*
  Copyright (c) 2008, Adobe Systems Incorporated
  All rights reserved.

  Redistribution and use in source and binary forms, with or without 
  modification, are permitted provided that the following conditions are
  met:

  * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
  
  * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the 
    documentation and/or other materials provided with the distribution.
  
  * Neither the name of Adobe Systems Incorporated nor the names of its 
    contributors may be used to endorse or promote products derived from 
    this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
  IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


package com.adobe.webapis.gettext
{
  import flash.errors.*;
  import flash.events.*;
  import flash.net.*;
  import flash.utils.*;
  
  public class GetText extends EventDispatcher
  {
    
    private static var singleton:GetText;
    
    public static const iso639_languageDict:Object = {
      "aa":"Afar. ",
      "ab":"Abkhazian",
      "ae":"Avestan",
      "af":"Afrikaans",
      "am":"Amharic",
      "ar":"Arabic",
      "as":"Assamese",
      "ay":"Aymara",
      "az":"Azerbaijani",
      "ba":"Bashkir",
      "be":"Byelorussian; Belarusian",
      "bg":"Bulgarian",
      "bh":"Bihari",
      "bi":"Bislama",
      "bn":"Bengali; Bangla",
      "bo":"Tibetan",
      "br":"Breton",
      "bs":"Bosnian",
      "ca":"Catalan",
      "ce":"Chechen",
      "ch":"Chamorro",
      "co":"Corsican",
      "cs":"Czech",
      "cu":"Church Slavic",
      "cv":"Chuvash",
      "cy":"Welsh",
      "da":"Danish",
      "de":"German",
      "dz":"Dzongkha; Bhutani",
      "el":"Greek",
      "en":"English",
      "eo":"Esperanto",
      "es":"Spanish",
      "et":"Estonian",
      "eu":"Basque",
      "fa":"Persian",
      "fi":"Finnish",
      "fj":"Fijian; Fiji",
      "fo":"Faroese",
      "fr":"French",
      "fy":"Frisian",
      "ga":"Irish",
      "gd":"Scots; Gaelic",
      "gl":"Gallegan; Galician",
      "gn":"Guarani",
      "gu":"Gujarati",
      "gv":"Manx",
      "ha":"Hausa (?)",
      "he":"Hebrew (formerly iw)",
      "hi":"Hindi",
      "ho":"Hiri Motu",
      "hr":"Croatian",
      "hu":"Hungarian",
      "hy":"Armenian",
      "hz":"Herero",
      "ia":"Interlingua",
      "id":"Indonesian (formerly in)",
      "ie":"Interlingue",
      "ik":"Inupiak",
      "io":"Ido",
      "is":"Icelandic",
      "it":"Italian",
      "iu":"Inuktitut",
      "ja":"Japanese",
      "jv":"Javanese",
      "ka":"Georgian",
      "ki":"Kikuyu",
      "kj":"Kuanyama",
      "kk":"Kazakh",
      "kl":"Kalaallisut; Greenlandic",
      "km":"Khmer; Cambodian",
      "kn":"Kannada",
      "ko":"Korean",
      "ks":"Kashmiri",
      "ku":"Kurdish",
      "kv":"Komi",
      "kw":"Cornish",
      "ky":"Kirghiz",
      "la":"Latin",
      "lb":"Letzeburgesch",
      "ln":"Lingala",
      "lo":"Lao; Laotian",
      "lt":"Lithuanian",
      "lv":"Latvian; Lettish",
      "mg":"Malagasy",
      "mh":"Marshall",
      "mi":"Maori",
      "mk":"Macedonian",
      "ml":"Malayalam",
      "mn":"Mongolian",
      "mo":"Moldavian",
      "mr":"Marathi",
      "ms":"Malay",
      "mt":"Maltese",
      "my":"Burmese",
      "na":"Nauru",
      "nb":"Norwegian Bokmål",
      "nd":"Ndebele, North",
      "ne":"Nepali",
      "ng":"Ndonga",
      "nl":"Dutch",
      "nn":"Norwegian Nynorsk",
      "no":"Norwegian",
      "nr":"Ndebele, South",
      "nv":"Navajo",
      "ny":"Chichewa; Nyanja",
      "oc":"Occitan; Provençal",
      "om":"(Afan) Oromo",
      "or":"Oriya",
      "os":"Ossetian; Ossetic",
      "pa":"Panjabi; Punjabi",
      "pi":"Pali",
      "pl":"Polish",
      "ps":"Pashto, Pushto",
      "pt":"Portuguese",
      "qu":"Quechua",
      "rm":"Rhaeto-Romance",
      "rn":"Rundi; Kirundi",
      "ro":"Romanian",
      "ru":"Russian",
      "rw":"Kinyarwanda",
      "sa":"Sanskrit",
      "sc":"Sardinian",
      "sd":"Sindhi",
      "se":"Northern Sami",
      "sg":"Sango; Sangro",
      "si":"Sinhalese",
      "sk":"Slovak",
      "sl":"Slovenian",
      "sm":"Samoan",
      "sn":"Shona",
      "so":"Somali",
      "sq":"Albanian",
      "sr":"Serbian",
      "ss":"Swati; Siswati",
      "st":"Sesotho; Sotho, Southern",
      "su":"Sundanese",
      "sv":"Swedish",
      "sw":"Swahili",
      "ta":"Tamil",
      "te":"Telugu",
      "tg":"Tajik",
      "th":"Thai",
      "ti":"Tigrinya",
      "tk":"Turkmen",
      "tl":"Tagalog",
      "tn":"Tswana; Setswana",
      "to":"Tonga",
      "tr":"Turkish",
      "ts":"Tsonga",
      "tt":"Tatar",
      "tw":"Twi",
      "ty":"Tahitian",
      "ug":"Uighur",
      "uk":"Ukrainian",
      "ur":"Urdu",
      "uz":"Uzbek",
      "vi":"Vietnamese",
      "vo":"Volapük; Volapuk",
      "wa":"Walloon",
      "wo":"Wolof",
      "xh":"Xhosa",
      "yi":"Yiddish (formerly ji)",
      "yo":"Yoruba",
      "za":"Zhuang",
      "zh":"Chinese",
      "zh_tw":"Chinese Transitional",
      "zh_cn":"Chinese Simplified",
      "zu":"Zulu"
    };
    
    private var translations:Object;
    
    private var name:String;
    
    private var language:String;
    
    private var charset:String;
    
    private var url:String;
    
    private var info:Object;
    
    private var xstream:URLStream;
    
    public function GetText(param1:Function = null)
    {
      super();
    }
    
    public static function getInstance() : GetText
    {
      if(GetText.singleton == null)
      {
        GetText.singleton = new GetText(arguments.callee);
      }
      return GetText.singleton;
    }
    
    public static function FindLanguageInfo(code:String) : String
    {
      if(iso639_languageDict.hasOwnProperty(code))
      {
        return iso639_languageDict[code];
      }
      return "";
    }
    
    public function getUrl() : String
    {
      return this.url;
    }
    
    public function getName() : String
    {
      return this.name;
    }
    
    protected function composeURLRequest() : URLRequest
    {
      return new URLRequest(this.url + this.getLocale() + "/" + this.name + ".mo");
    }
    
    final public function install() : void
    {
      var _loc1_:URLRequest = this.composeURLRequest();
      this.xstream = new URLStream();
      this.xstream.addEventListener(Event.COMPLETE,this.handleEvent);
      this.xstream.addEventListener(Event.OPEN,this.handleEvent);
      this.xstream.addEventListener(ProgressEvent.PROGRESS,this.handleEvent);
      this.xstream.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.handleEvent);
      this.xstream.addEventListener(IOErrorEvent.IO_ERROR,this.handleEvent);
      this.xstream.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleEvent);
      this.xstream.load(_loc1_);
    }
    
    final public function translation(name:String, url:String, language:String) : void
    {
      this.url = "locale/";
      if(url.length > 0)
      {
        this.url = url;
      }
      this.name = name;
      this.language = language;
    }
    
    public function getLocale() : String
    {
      return this.language;
    }
    
    protected function handleEvent(event:Event) : void
    {
      if(event.type == Event.COMPLETE)
      {
        var byte:ByteArray = new ByteArray();
        byte.endian = Endian.LITTLE_ENDIAN;
        event.target.readBytes(byte,0,event.target.bytesAvailable);
        try
        {
          var retObject:Object = Parser.parse(byte);
          this.translations = retObject.translation;
          this.info = retObject.info;
          this.charset = retObject.charset;
        }
        catch(e:Error)
        {
          var errEvent:ErrorEvent = new ErrorEvent(ErrorEvent.ERROR,true,false,"EOFError: " + e.message);
          this.dispatchEvent(errEvent);
          return;
        }
      }
      var evt:Event = new Event(event.type,true,true);
      this.dispatchEvent(evt);
    }
    
    public function translate(id:String, exception404:Boolean = false) : String
    {
      try
      {
        if(this.translations.hasOwnProperty(id))
        {
          return this.translations[id];
        }
        throw new TypeError();
      }
      catch(e:TypeError)
      {
        if(exception404)
        {
          throw e;
        }
        return id;
      }
      return "";
    }
  }
}

