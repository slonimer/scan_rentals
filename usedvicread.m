function usedvicread(par)
% https://www.usedvictoria.com/classifieds/real-estate-rentals?seller_type=
% &attr_7_from= numBedrooms
% &attr_7_to= numBedrooms
% &attr_8_from= numBathrooms
% &attr_8_to= numBathrooms
% &attr_9_from= squareFootage
% &attr_9_to= squareFootage
% &attr_10= pets (YES, NO, or empty)
% &attr_11= smoking (YES, NO, or empty)
% &attr_14= MLS number
% &location=Victoria+City&location=Oak+Bay&location=Saanich
% &pricefrom=1000
% &priceto=1500
% &description= keywords seperated by %2C+


%Create url for Us
% locations{1} = 'Victoria+City';
% locations{2} = 'Oak+Bay';
% locations{3} = 'Saanich';
%minPrice = '1000';
%maxPrice = '1500';
%keyWords = 'uvic%2C+camosun%2C+cedarhill%2C+hillside%2C+fernwood%2C+quadra';
keyWords = ''; %I'm worried about overly-limiting it

link=strtrim(strcat('https://www.usedvictoria.com/classifieds/real-estate-rentals?seller_type=',...
    '&categories=house-rentals',...
    '&categories=apartment-rentals',...
    '&attr_7_from=',...
    '&attr_7_to=',...
    '&attr_8_from=',...
    '&attr_8_to=',...
    '&attr_9_from=',...
    '&attr_9_to='));
if par.pets==1
        link = strtrim(strcat(link,...
        '&attr_10=YES'));
else
        link = strtrim(strcat(link,...
        '&attr_10='));
end
link = strtrim(strcat(link,...
    '&attr_11=',...
    '&attr_14='));
for ii = 1:length(par.locations)
    link = strtrim(strcat(link,...
        '&location=',par.locations{ii}));
    %'&location=',locations{1},...
%'&location=',locations{2},...
%'&location=',locations{3},...
end
link = strtrim(strcat(link,...
    '&pricefrom=',par.minPrice,...
    '&priceto=',par.maxPrice,...
    '&description=',keyWords));


% usedLinkForThem=strtrim(strcat('https://www.usedvictoria.com/classifieds/real-estate-rentals?seller_type=',...
% '&categories=house-rentals',...
% '&categories=apartment-rentals',...
% '&attr_7_from=',...
% '&attr_7_to=',...
% '&attr_8_from=',...
% '&attr_8_to=',...
% '&attr_9_from=',...
% '&attr_9_to=',...
% '&attr_10=',...
% '&attr_11=',...
% '&attr_14=',...
% '&location=',locations{1},...
% '&location=',locations{4},...
% '&pricefrom=',minPrice,...
% '&priceto=',maxPrice,...
% '&description=',keyWords));


path = which('scanallsites');
[folder,~,~] = fileparts(path);
% folder = pwd;
            scan_usedvic_url(link,fullfile(folder,par.txtFile),par.badWords,par.phoneNumbers,par.email);
            %scan_usedvic_url(usedLinkForThem,fullfile(folder,'housingListsThem.txt'),[]);



end





function scan_usedvic_url(link,housingListFile,badWords,phoneNumbers,email)

%Script to scrape relevant part of craigslist, compare to list
%already saved. Add any new links and email a notification with the url

%Load Saved Data
fileID = fopen(housingListFile);
tempFile = textscan(fileID,'%s');
savedData=tempFile{1};


stuff=webread(link);
% expression= 'rdf:resource=\"(.*?)\"';
% matchStr = regexp(stuff,expression,'match')';  

list_expression = 'Recent Ads';
listings = strfind(stuff,list_expression);
stuff = stuff(listings(1):end);

list_expression = '$(function()';%'<p class="result-info">';
listings = strfind(stuff,list_expression);

%Search for unique links - Regular expression for HTML repersenting the links
expression_1 = 'href=\"(.*?)\"';
%expression_2 = 'datetime=\"(.*?)\"';

% expression_2 = 'p class="title">\s\$\d &nbsp';
% expression_2 = 'span class="result-price">\$\d{4}<';
% expression_3 = 'span class="result-price">\$\d{3}<';

%Expression to look for in each ad:
ad_expression = 'meta property="og:description" content=\"(.*?)\"';
ad_expression2 = 'var locationName = \"(.*?)\"';

for ii=1:length(listings)
    if ii~=length(listings)
        subStuff = stuff(listings(ii):listings(ii+1)-1);
    else
        subStuff = stuff(listings(ii):end);
    end
    %Get the link for each listing:
    matchStr_1 = regexp(subStuff,expression_1,'match')';  
    matchStr_1 = matchStr_1(2); %Only retain the second 
  
    %Get the price for each listing:
    %matchStr_2 = regexp(subStuff,expression_2,'match')';  
    %matchStr_2 = matchStr_2(1); %Only retain the first

    temp = char(matchStr_1{1});
    indx=strfind(temp,'"');

    matchStr = strcat('https://www.usedvictoria.com',temp(indx(1)+1:indx(2)-1));

    check=0;
    for ct2=1:length(savedData)
        check=strcmp(matchStr,savedData{ct2})+check;
    end
    if check == 0
       
        %Check to see if any badWords are included. If so, don't send a message
        adStr = webread(matchStr);
        adMatchStr= regexp(adStr,ad_expression,'match')';  
        adMatchStr2= regexp(adStr,ad_expression2,'match')';  
        for jj=1:length(badWords)
            %Check the Ad Title
            if contains(matchStr,badWords{jj},'IgnoreCase',true)
                check=1;
            end
            %Check the Ad Text
            if contains(adMatchStr{1},badWords{jj},'IgnoreCase',true)
            %if strfind(matchStr,badWords{jj})~=0
                check=1;
            end
            %Check the Location Text
            if contains(adMatchStr2{1},badWords{jj},'IgnoreCase',true)
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
                        sendmail(phoneNumbers{jj}, 'New UsedVic Listing!!', matchStr);
                        %sendmail('2504192206@msg.telus.com', 'New Kijiji Listing!!', matchStr);
                        end
                    end
                    %Email:
                    for jj = 1:length(email) %A cell array
                        if ~isempty(email{jj})
                        sendmail(email{jj}, 'New usedVic Listing!!', matchStr);
                        end
                    end
                    %sendmail('alexslonimerrentals@gmail.com', 'New Kijiji Listing!!', matchStr);
                    
                    %open the history of what's been found so far, and add this link to this list
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

