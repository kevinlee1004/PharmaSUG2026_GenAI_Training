/* Step 1: Read API Key */
filename apifile "E:\SASData\klee\GenAI\api_key.txt";

data _null_;
    infile apifile truncover;
    input line $200.;
    
    if index(line, '=') > 0 then do;
        /* Remove spaces */
        *line = compress(line, ' ', 'k');
        
        /* Separate key and value */
        key = scan(line, 1, '=');
        val = scan(line, 2, '=');

        /* Remove surrounding quotes if they exist */
        *val = strip(tranwrd(tranwrd(val, '"', ''), "'", ''));

        /* Assign to macro variable */
        call symputx(key, val);
    end;
run;


/* Step 2: Set Up Prompt and respose files */
filename resp "E:\project\CodeZen\klee\resp_gemini.json";
filename in temp;

data _null_;
    file in ;
    put '{';
    put '  "contents": [';
    put '    { "parts": [ {"text": "Write a short summary about clinical trials."} ] }';
    put '  ]';
    put '}';
run;

*%let url = https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent;
%let url = https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent;
%let url_query = &url.?key=&gemini_api.;

%put &url_query;
%put &url;
%put &gemini_api. ;

/* Step 3: Send prompt to OpenAI */
proc http 
 method = "POST" 
 url	= "&url_query."
 in		= in 
 out	= resp
 ct 	= "application/json"
 ;

run; 
quit;

/* Step 4: Read response json files in the local drive */
libname response JSON fileref=resp;


data r_sas;
	set response.content_parts
	;
run;

proc print data=r_sas; run;



