function scanallsites_wCatFacts

%Define the Minimum and Maximum Prices:
minPrice = '1000';
maxPrice = '1700';

%Define words to exclude from search:
badWords = {'wanted','bachelor','studio','sublet','interurban','langford','shawnigan',...
    'pender','saltspring','tillicum','gorge','vicwest',...
    'jamesbay','cordova','superior','royaloak'};

%Email Setup
mail = 'alexslonimerrentals@gmail.com';    % Replace with your email address
password = '';          % Replace with your email password
server = 'smtp.gmail.com';     % Replace with your SMTP server

%Initialize a counter for the cat facts:
n=9;
%Scan the url's from now until July 15
presentDate = now;
while presentDate < datenum(2019,07,15)
    
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
    
    %Scan the Craigslist Links:
    try
        %craigslistread(minPrice,maxPrice,badWords);
        fprintf('\nCraiglist scan complete');
    catch
        %Carry on
        fprintf('\nCraiglist scan failed');
    end
    fclose all;
    
    %Scan the UsedVic Links:
    try
        %usedvicread(minPrice,maxPrice,badWords);
        fprintf('\nUsedVic scan complete');
    catch
        %Carry on
        fprintf('\nUsedVic scan failed');
    end
    fclose all;
    
    %Scan the Kijiji Links:
    try
        %kijijiread(minPrice,maxPrice,badWords);
        fprintf('\nKijiji scan complete');
    catch
        %Carry on
        fprintf('\nKijiji scan failed');
    end
    fclose all;
    
    
    %***************************************
    %Send a daily cat fact:
    if presentDate > datenum(2019,05,25+n,09,00,00)
        dailycatfacts(n);
        n=n+1;
    end
    %***************************************
    
    %Pause for 2 minutes (120 seconds), then do it again
    pause(120);
    presentDate = now;
    
    
end


end