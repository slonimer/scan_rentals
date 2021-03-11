function scanallsites_wPar
%Define the Minimum and Maximum Prices:
% minPrice = '1000';
% maxPrice = '1700';

%Define words to exclude from search:
% badWords = {'wanted','bachelor','studio','sublet','interurban','langford','shawnigan',...
%     'pender','saltspring','tillicum','gorge','vicwest',...
%     'jamesbay','cordova','superior','royaloak'};

%Email Setup
mail = 'alexslonimerrentals@gmail.com';    % Replace with your email address
password = '';          % Replace with your email password
server = 'smtp.gmail.com';     % Replace with your SMTP server

%Initialize a counter for the cat facts:
% n=9;
%Scan the url's from now until October 15
presentDate = now;
while presentDate < datenum(2021,01,01)
    
    % Apply prefs
    try
        setpref('Internet','SMTP_Server',server);
        setpref('Internet','E_mail',mail);
        setpref('Internet','SMTP_Username',mail);
        setpref('Internet','SMTP_Password',password);
        
        % Apply props
        props = java.lang.System.getProperties;
        props.setProperty('mail.smtp.auth','true'); % Replace your settings
        props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');% Replace your settings
        props.setProperty('mail.smtp.socketFactory.port','465');% Replace your settings
        
        fprintf('\n****************\nInternet Preferences Applied\n****************');
    catch
        %Carry on
        fprintf('\nInternet Properties and preferences failed');
    end
    
    
    %Print time:
    fprintf('\n\nScanning....%s',datestr(now,'yyyy/mm/dd HH:MM:SS'));
    
    for ii = 1 %1:4
        clear par
        %Each kalisa parFile has a different radius and location. 
        if ii==1
            fprintf('\nScanning for First Par File');
            spencer_parFile;
            %toni_parFile;
            %alex_parFile;
        elseif ii==2
            fprintf('\nScanning for Second Par File');
            %kalisa_parFile2;
        elseif ii==3
            fprintf('\nScanning for Third Par File');
            %kalisa_parFile3;
            %maddy_parFile;
        elseif ii==4
            fprintf('\nScanning for Fourth Par File');
            %alex_parFile;
           % alex_parFile;
            %maddy_parFile;
        end
    
        %Craigslist and Kijiji Use a postal code and a distanceKm radius.
        %  Kijiji also uses a lat/lon coordinate 
        %The 'location' for craigslist specifies a broad city (ie victoria, vancouver)
        %The 'location' for usedvic is a keyword that specifies neighborhoods 
        
        %Scan the Craigslist Links:
        try
            %Use general parameters
            par1 = par;
            %Add locations specific for craigslist
            par1.locations= craigslistPar.locations;

            %Run
            craigslistread(par1);
            fprintf('\nCraiglist scan complete');
        catch
            %Carry on
            fprintf('\nCraiglist scan failed');
        end
        fclose all;
        
        %Scan the UsedVic Links:
        try
            %Use general parameters
            par2 = par;
            %Add locations specific for craigslist
            par2.locations= usedvicPar.locations;
            %Run
            usedvicread(par2);
            fprintf('\nUsedVic scan complete');
        catch
            %Carry on
            fprintf('\nUsedVic scan failed');
        end
        fclose all;
        
        %Scan the Kijiji Links:
        try
            %Run
            kijijiread(par);
            fprintf('\nKijiji scan complete');
        catch
            %Carry on
            fprintf('\nKijiji scan failed');
        end
        fclose all;
        
    end
    
    %***************************************
    %Send a daily cat fact:
    %if presentDate > datenum(2019,05,25+n,09,00,00)
    %    dailycatfacts(n);
    %    n=n+1;
    %end
    %***************************************
    
    %Pause for 2 minutes (120 seconds), then do it again
    pause(120);
    presentDate = now;
    
    
end


end

% 
% function inputPar = addPar(inputPar,par)
%     %Add generalized parameters to specific par:
%     inputPar.minPrice = par.minPrice;
%     inputPar.maxPrice = par.maxPrice;
%     inputPar.badWords = par.badWords;
%     inputPar.phoneNumbers = par.phoneNumbers;
%     inputPar.txtFile = par.txtFile;
% end

