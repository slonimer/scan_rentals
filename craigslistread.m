function craigslistread(par)
%Script to scrape relevant part of craigslist, compare to list
%already saved. Add any new links and email a notification with the url


%         %Email Setup
%         mail = 'alexslonimerrentals@gmail.com';    % Replace with your email address
%         password = '';          % Replace with your email password
%         server = 'smtp.gmail.com';     % Replace with your SMTP server
% 
%         % Apply prefs
%         setpref('Internet','SMTP_Server',server);
%         setpref('Internet','E_mail',mail);
%         setpref('Internet','SMTP_Username',mail);
%         setpref('Internet','SMTP_Password',password);
% 
%         % Apply props
%         props = java.lang.System.getProperties;
%         props.setProperty('mail.smtp.auth','true'); % Replace your settings
%         props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');% Replace your settings
%         props.setProperty('mail.smtp.socketFactory.port','465');% Replace your settings



category = 'apa';

if par.pets==1
    petStr = '&pets_cat=1&pets_dog=1';
else
    petStr = '';
end

%Create Url
link=strtrim(strcat('https://',par.locations,...
    '.craigslist.org/search/',category,...
    sprintf('?search_distance=%1.0f',par.distanceKm),...
    '&postal=',par.postalCode,...
    '&min_price=',par.minPrice,...
    '&max_price=',par.maxPrice,...
    '&availabilityMode=0',petStr,'&sale_date=all+dates'));


%Create url for Us
%Look for within 3km of around hillside, $1000 to $1500
% locations = 'victoria';
% category = 'apa';
% distanceKm = '4';
% postalCode = 'v8r4m4';
%  minPrice = '1000';
%  maxPrice = '1500';
% searchString = 'vicWest';
% craigsLinkForUs=strtrim(strcat('https://',locations,...
%     '.craigslist.org/search/',category,...
%     '?search_distance=',distanceKm,...
%     '&postal=',postalCode,...
%     '&min_price=',minPrice,...
%     '&max_price=',maxPrice,...
%     '&availabilityMode=0&sale_date=all+dates'));
    %'&availabilityMode=0&query=',searchString,...
    %'&sale_date=all+dates'));
     
 
    
%Scan the url's from now until July 15
% presentDate = now;

%         while presentDate < datenum(2019,07,15)
%             %Scan the Craigslist Links:
path = which('scanallsites');
[folder,~,~] = fileparts(path);
% folder = pwd;
            scan_craigslist_url(link,fullfile(folder,par.txtFile),par.badWords,par.phoneNumbers,par.email);
%             scan_craigslist_url(craigsLinkForThem,fullfile(folder,'housingListsThem.txt'),[]);
%             %Only do this once every 10 minutes (600 seconds).
%             pause(600);
%             presentDate = now;
%         end
    

end



function scan_craigslist_url(link,housingListFile,badWords,phoneNumbers,email)

%Script to scrape relevant part of craigslist, compare to list
%already saved. Add any new links and email a notification with the url

%Load Saved Data
fileID = fopen(housingListFile);
tempFile = textscan(fileID,'%s');
savedData=tempFile{1};


stuff=webread(link);
% expression= 'rdf:resource=\"(.*?)\"';
% matchStr = regexp(stuff,expression,'match')';  
list_expression = '<p class="result-info">';
listings = strfind(stuff,list_expression);

%Search for unique links - Regular expression for HTML repersenting the links
expression_1 = 'href=\"(.*?)\"';
expression_2 = 'span class="result-price">\$\d{4}<';
expression_3 = 'span class="result-price">\$\d{3}<';
% <span class="result-price">$1295</span>

%Expression to look for in each ad:
ad_expression = 'meta property="og:description" content=\"(.*?)\"';

%expression_2 = 'datetime=\"(.*?)\"';
for ii=1:length(listings)
    if ii~=length(listings)
        subStuff = stuff(listings(ii):listings(ii+1)-1);
    else
        subStuff = stuff(listings(ii):end);
    end
    %Get the link for each listing:
    matchStr_1 = regexp(subStuff,expression_1,'match')';  
    matchStr_1 = matchStr_1(1); %Only retain the first 
    %Get the price for each listing:
    matchStr_2 = regexp(subStuff,expression_2,'match')';
    matchStr_2 = matchStr_2{1}(27:31); %Only retain the first 
    if isempty(matchStr_2)
        %Below $1000
        matchStr_2 = regexp(subStuff,expression_3,'match')';
        matchStr_2 = matchStr_2{1}(27:30); %Only retain the first 
    end
    
    temp = char(matchStr_1{1});
    indx=strfind(temp,'"');

    matchStr = temp(indx(1)+1:indx(2)-1);
    check=0;
    for ct2=1:length(savedData)
        check=strcmp(matchStr,savedData{ct2})+check;
    end
    if check == 0
        
        %Check to see if any badWords are included. If so, don't send a message
        adStr = webread(matchStr);
        adMatchStr= regexp(adStr,ad_expression,'match')';  
        for jj=1:length(badWords)
            %Check the Ad Title
            if contains(matchStr,badWords{jj},'IgnoreCase',true)
            %if strfind(matchStr,badWords{jj})~=0
                check=1;
            end
            %Check the Ad Text
            if contains(adMatchStr,badWords{jj},'IgnoreCase',true)
            %if strfind(matchStr,badWords{jj})~=0
                check=1;
            end
        end
        
        if check==0
            % Send the email

            try
                %Text Message
                for jj = 1:length(phoneNumbers) %A cell array
                    if ~isempty(phoneNumbers{jj})
                    sendmail(phoneNumbers{jj}, 'New CraigsList Listing!!', matchStr);
                    %sendmail('2504192206@msg.telus.com', 'New Kijiji Listing!!', matchStr);
                    end
                end
                %Email:
                for jj = 1:length(email) %A cell array
                    if ~isempty(email{jj})
                    sendmail(email{jj}, 'New CraigsList Listing!!', matchStr);
                    end
                end
                %sendmail('alexslonimerrentals@gmail.com', 'New Kijiji Listing!!', matchStr);
                
                %After mailing, open the history of what's been found so far, and add this link to this list
                fid = fopen(housingListFile,'a'); fprintf(fid,'%s\n', matchStr); fclose(fid);
            catch
                %Do nothing, and don't add to the list history
            end
            
            pause(1);
            
        else %Add to the list so it doesnt come up again
            %Open the history of what's been found so far, and add this link to this list
            fid = fopen(housingListFile,'a'); fprintf(fid,'%s\n', matchStr); fclose(fid);
        end
        
    end
end

end