% --- Standard figure toolbar buttons --- %

% I am using 2007b, and here is how I get to these handles:

set(0,'Showhidden','on')
figure
ch = get(gcf,'children');
UT = get(ch(9),'children');

deleteInd = [1 2 3 4 5 6 8 9 13 14 15 16];
delete(UT(deleteInd))

% Now UT is a 14x1 vector with the handles to those little buttons. UT(1)
% is the rightward most button, and UT(end) is the leftward most button.
% Use delete(UT(#)) to get rid of a button.