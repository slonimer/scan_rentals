function kijijiread(par)
%
% With Kijiji, no nice way to do Apartments, Condos, and House Rentals.
% it's either All or One, so Need to do 2 links per search
% 

%Apartments and Condos
% https://www.kijiji.ca/b-apartments-condos/victoria-bc/c37l1700173r3.0?ll=48.440844,-123.333895&address=v8r4m4&ad=offering&price=1000__1500
% https://www.kijiji.ca/b-apartments-condos/victoria-bc/c37l1700173r1.0?ll=48.435154,-123.390729&address=v9a3c8&ad=offering&price=1000__1500

%House Rentals
% https://www.kijiji.ca/b-house-rental/victoria-bc/c43l1700173r3.0?ad=offering&price=1000__1500&address=v8r4m4&ll=48.440844,-123.333895

%Min only
% https://www.kijiji.ca/b-house-rental/victoria-bc/c43l1700173r3.0?ll=48.440844,-123.333895&address=v8r4m4&ad=offering&price=1000__

%Need to fill out these fields in the par file. These get entered from the
%calling function
%     par.minPrice = '1000';
%     par.maxPrice = '1500';
%     par.badWords = {};%cellarray
%     par.distanceKm = 4;
%     par.lat = 48.440844;
%     par.lon = -123.333895;
%     par.postalcode = 'v8r4m4';
%     
%     par.phoneNumbers{1} = '5555555555@msg.telus.com';
%     par.phoneNumbers{2} = '5555555556@msg.telus.com';
%     par.txtFile = 'housingListsUs.txt';

% textread(par);


rentalType{1} = 'apartments-condos';
rentalType{2} = 'house-rental';

rentalCode{1} = 'c37l1700173';
rentalCode{2} = 'c43l1700173';

%Need to do 2 scans.  One for apartments, and one for houses
for n = 1:2
    %Input Param:
    distanceKm = par.distanceKm;
    lat = par.lat;%48.440844
    lon = par.lon;%-123.333895
    postalcode = par.postalCode;%v8r4m4
    coords = sprintf('r%1.0f.0?ll=%1.6f,%1.6f&address=%s', distanceKm, lat, lon, postalcode );
    if par.pets==1 
        petStr = '&pet-friendly=1';
    else
        petStr = '';
    end
    priceStr = strcat('&price=',par.minPrice,'__',par.maxPrice);
    link = strcat('https://www.kijiji.ca/b-',rentalType{n},...
        '/victoria-bc/',rentalCode{n},coords,...
        '&ad=offering',...
        priceStr,petStr);
    
    %Us:
    %distanceKm = '4';
    %coords = strcat('r',distanceKm,'.0?ll=48.440844,-123.333895&address=v8r4m4');
    % minPrice = '1000';
    % maxPrice = '1500';
    %priceStr = strcat('&price=',minPrice,'__',maxPrice);
    %linkForUs = strcat('https://www.kijiji.ca/b-',rentalType{n},...
    %    '/victoria-bc/',rentalCode{n},coords,...
    %    '&ad=offering',...
    %    priceStr);


path = which('scanallsites');
[folder,~,~] = fileparts(path);
    scan_kijiji_url(link,fullfile(folder,par.txtFile),par.badWords,par.phoneNumbers,par.email);
    %scan_kijiji_url(linkForUs,fullfile(folder,'housingListsUs.txt'),badWords);
    %scan_kijiji_url(linkForThem,fullfile(folder,'housingListsThem.txt'),[]);
end


end





function scan_kijiji_url(link,housingListFile,badWords,phoneNumbers,email)

%Script to scrape relevant part of craigslist, compare to list
%already saved. Add any new links and email a notification with the url

%Load Saved Data
fileID = fopen(housingListFile);
tempFile = textscan(fileID,'%s');
savedData=tempFile{1};


stuff=webread(link);
% expression= 'rdf:resource=\"(.*?)\"';
% matchStr = regexp(stuff,expression,'match')';  

list_expression = 'adsense-bottom-bar';
listings = strfind(stuff,list_expression);
if ~isempty(listings)
    stuff = stuff(listings(1):end);
end

list_expression = 'data-listing-id';%'<p class="result-info">';
%list_expression = 'data-ad-id';%'<p class="result-info">';
listings = strfind(stuff,list_expression);


%Search for unique links - Regular expression for HTML repersenting the links
expression_1 = 'data-vip-url=\"(.*?)\"';
%expression_2 = 'datetime=\"(.*?)\"';
% expression_2 = 'div class="price">\s\$\d<';
%  <div class="price">
%                                  $1,500.00</div>

%Expression to look for in each ad:
ad_expression = 'meta name="description" content=\"(.*?)\"';

for ii=1:length(listings)
    if ii~=length(listings)
        subStuff = stuff(listings(ii):listings(ii+1)-1);
    else
        subStuff = stuff(listings(ii):end);
    end
    %Get the link and date for each listing:
    matchStr_1 = regexp(subStuff,expression_1,'match')';  
    matchStr_1 = matchStr_1(1); %Only retain the second 
    %Get the price for each listing:
%         matchStr_2 = regexp(subStuff,expression_2,'match')';
%         matchStr_2 = matchStr_2{1}(27:31); %Only retain the first 
%         if isempty(matchStr_2)
%             %Below $1000
%             matchStr_2 = regexp(subStuff,expression_3,'match')';
%             matchStr_2 = matchStr_2{1}(27:30); %Only retain the first 
%         end

    temp = char(matchStr_1{1});
    indx=strfind(temp,'"');

    matchStr = strcat('https://www.kijiji.ca',temp(indx(1)+1:indx(2)-1));

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
                    sendmail(phoneNumbers{jj}, 'New Kijiji Listing!!', matchStr);
                    %sendmail('2504192206@msg.telus.com', 'New Kijiji Listing!!', matchStr);
                    end
                end
                %Email:
                for jj = 1:length(email) %A cell array
                    if ~isempty(email{jj})
                    sendmail(email{jj}, 'New Kijiji Listing!!', matchStr);
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
            %open the history of what's been found so far, and add this link to this list
            fid = fopen(housingListFile,'a'); fprintf(fid,'%s\n', matchStr); fclose(fid);
        end
        
    end
end

end