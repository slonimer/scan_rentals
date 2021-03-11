par.minPrice = '2000';
par.maxPrice = '3200';
par.badWords = {'wanted','bachelor','studio','1Br','1 Br',...
    'sublet','short term','short-term','temporary',...
    'shawnigan','duncan','nanaimo','malahat','pender','saltspring',...
    'sidney','cordova','royaloak','royal oak',...
    'tattersall','uptown','carey','vanalman','glanford',...
    'langford','metchosin','colwood','royal roads',...
    'interurban',...
    'coin laundry','coin op laundry','coin-op laundry',...
    'senior',...
    'absolutely no pets','no cats',...
    };

par.pets = 1; %pet friendly
%par.pets = 0; %pets are not yes or no

par.phoneNumbers{1} = '';
%par.phoneNumbers{1} = '5555555555@msg.telus.com';
%par.phoneNumbers{2} = '5555555556@pcs.rogers.com';
%
% par.email{1} = '';
par.email{1} = 'person1@gmail.com';
par.email{2} = 'person2bunn@gmail.com';

%Output Text File:
par.txtFile = 'userLists.txt';


%Radius around some Postal Code or lat/lon coordinate:
par.distanceKm = 4;
par.lat = 48.440205;
par.lon = -123.353883;
par.postalCode = 'v8t2a9';

%Locations for craigslist (city/region)
craigslistPar.locations = 'victoria';

%Locations for UsedVic (neighborhoods)
usedvicPar.locations{1} = 'Victoria+City';
usedvicPar.locations{2} = 'Oak+Bay';
usedvicPar.locations{3} = 'Saanich';
usedvicPar.locations{4} = 'Esquimalt';


% craigslistPar.locations = 'victoria';
% craigslistPar.category = 'apa';
% craigslistPar.distanceKm = '4';
% craigslistPar.postalCode = 'v8r4m4';

% usedvicPar.locations{1} = 'Victoria+City';
% usedvicPar.locations{2} = 'Oak+Bay';
% usedvicPar.locations{3} = 'Saanich';
% usedvicPar.locations{4} = 'Esquimalt';

kijijiPar.distanceKm = 4;
kijijiPar.lat = 48.440205;
kijijiPar.lon = -123.353883;
kijijiPar.postalcode = 'v8t2a9';


