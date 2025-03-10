% 27/09/2017 Show the results for multi-contrast MRI reconstruction based
% coupled dictionary learning (CDLMRI)
% 27/11/2017 Use T2 multi-slices.

% clear;
close all;

addpath('../export_fig');
% addpath('../Test_RGB_NIR');
addpath('./utils');
%% set the line size and position of boxes in figure;
show_figure = 1; % show figure or not
save_figure = 1 ; % save or not ;

FigFormat = ['.png']; % ['.png'] ; % ['.jpg'] ; % ['.eps'];

% ImHeigth = 422;
% ImWidth = 562;

lineSize = 2; 
lineSize2 = 1;
wSize = [50, 50]; % width
PosStart_cell = {[105, 140] };  

ScaleFac = 1;
lineSize_low = ceil(lineSize/ScaleFac);
wSize_low = round( wSize./ScaleFac); 

for j = 1 : length(PosStart_cell)
	PosStart_cell_low{j} = round(PosStart_cell{j}./ScaleFac);
end

for j= 1: length(PosStart_cell)
	PosStart = PosStart_cell{j}; % x,y position for starting 
	if PosStart(1) <= lineSize || PosStart(2) <= lineSize
		disp('starting position is not larger than the line width.')	
	end
end

%% load data

% 	% select the corresponding method and images !!
MethodNames = {'CDLMRI'};	
ImNames = {'*BrainWebA*', '*BrainWebB*', '*BrainWebC*', ...
	'*patientA*', '*patientB*', '*patientC*', '*XXXX*' };

% load testing images.

% image size
NUMROWS = 256;
NUMCOLS = 256;

%load real MRI data
XpathCell = {'./MRI_Slices_Imgs/T2Slices_SZ256.mat'};
YpathCell = XpathCell;
load './MRI_Slices_Imgs/T2Slices_SZ256.mat';
im = T2Slices(:,:,1);
im =  im./ max(abs(im(:)));
Ycell{1} = imresize(im, [NUMROWS, NUMCOLS], 'bicubic');

im = T2Slices(:,:,2);
im =  im./ max(abs(im(:)));
Xcell{1} = imresize(im, [NUMROWS, NUMCOLS], 'bicubic');

% directoryX = '../TestImages_MRI'; 
% directoryY = '../TestImages_MRI'; 
% patternX = '*T1.png';
% patternY = '*T2.png';
% 
% XpathCell = glob(directoryX, patternX );
% Xcell = load_images( XpathCell );
% for i =1 : length(Xcell)
% 	Xcell{i} = imresize(Xcell{i}, [NUMROWS, NUMCOLS], 'bicubic');
% end
% 
% YpathCell = glob(directoryY, patternY );
% Ycell = load_images(YpathCell );
% % Ycell = load_True_images(YpathCell );
% for i =1 : length(Ycell)
% 	Ycell{i} = imresize(Ycell{i}, [NUMROWS, NUMCOLS], 'bicubic');
% end

% 	figure; subplot(1,2,1); imshow(Xcell{1}); subplot(1,2,2); imshow(Ycell{1});
if length(Xcell) ~= length(Ycell)	
	error('Error: The number of X images is not equal to the number of Y images!');
end

% Normalize and truncate interpolated images in order to limit the pixel value between 0 and 1.
for i =1 : length(Xcell)
	Img = Xcell{i} ;
	Img = Img./max(abs(Img(:)));
	Img( Img > 1) = 1 ;
	Img( Img < 0) = 0 ;		
	Xcell{i} = Img ;

	Img = Ycell{i} ;
	Img = Img./max(abs(Img(:)));
	Img( Img > 1) = 1 ;
	Img( Img < 0) = 0 ;		
	Ycell{i} = Img ;		
end	

% % rotate some images by 90 degree.
% for i= 1:2
% 	if ~isempty(Result_cell{i})
% 		Result_cell{i}.Iout1.A = rot90(Result_cell{i}.Iout1.A) ;
% 		Result_cell{i}.Iout1.B = rot90(Result_cell{i}.Iout1.B) ;
% 		Xcell{i} = rot90(Xcell{i}) ;
% 		Ycell{i} = rot90(Ycell{i}) ;
% 	end
% end

%% draw figure
ImgNum = length(Result_cell) ; 
fold = DLMRIparams.fold ;

for i = 1
% 	for i = 1: ImgNum

	% matlab map
	myCmap = colormap(gray);

	FileNameCom = ['ImgNo', num2str(i), '_Fold', num2str(fold) ];
	BoxColor = [1,1,0]; % yellow.

	% True SI image ------------------------------------------------
	Y_test = Ycell{i}; % testing image Y
	PosStart = PosStart_cell{i}; % x,y position for starting 

	[imWhole,imPiece] = ShowFigInFig(Y_test, PosStart, wSize, lineSize, BoxColor);


	if show_figure
		figure;
		imagesc(imWhole); hold on;
		set(gcf,'Position', [0,0,size(imWhole,2), size(imWhole,1)]); axis off
		set(gca, 'Position', [0,0,1,1]);

		axes('Position',[0,0,0.4*size(imWhole,1)/size(imWhole,2),0.4]); 
		imagesc(imPiece); axis off
		pause(0.2);
	end

	if save_figure
		FileName = ['ImgNo', num2str(i), '_SI_true'];
		export_fig(gcf,  [FileName, FigFormat], '-nocrop', '-transparent')   % export_fig(figure_handle, filename, , '-nocrop', '-transparent');		
	end

	% with SI ------------------------------------------------
	imX = abs(Result_cell{i}.Iout1.A)  ;	
% 		imX = shave(imX, [ScaleFac, ScaleFac]);	
	imX = im2double(imX);
	PosStart = PosStart_cell{i}; % x,y position for starting 

	[imWhole,imPiece] = ShowFigInFig(imX, PosStart, wSize, lineSize, BoxColor);
% 		imWhole(:,:,2:3) = [];	imPiece(:,:,2:3) = [];

	if show_figure
		figure;
		imagesc(imWhole); hold on;
		set(gcf,'Position', [300,0,size(imWhole,2), size(imWhole,1)]); axis off
		set(gca, 'Position', [0,0,1,1]);

		axes('Position',[0,0,0.4*size(imWhole,1)/size(imWhole,2),0.4]); 
		imagesc(imPiece); axis off
		colormap(myCmap)
		pause(0.2);
	end
	if save_figure
		FileName = [FileNameCom , '_X_', MethodNames{1}];
		export_fig(gcf,  [FileName, FigFormat], '-nocrop', '-transparent')   % export_fig(figure_handle, filename, , '-nocrop', '-transparent');		
	end

	% True test image ------------------------------------------------
	X_GT = Xcell{i}; % ground true testing image X
	X_GT = im2double(X_GT);
	PosStart = PosStart_cell{i}; % x,y position for starting 

	[imWhole,imPiece] = ShowFigInFig(X_GT, PosStart, wSize, lineSize, BoxColor);
% 		imWhole(:,:,2:3) = [];	imPiece(:,:,2:3) = [];

	if show_figure
		figure;
		imagesc(imWhole); hold on;
		set(gcf,'Position', [600,0,size(imWhole,2), size(imWhole,1)]); axis off
		set(gca, 'Position', [0,0,1,1]);

		axes('Position',[0,0,0.4*size(imWhole,1)/size(imWhole,2),0.4]); 
		imagesc(imPiece); axis off
		colormap(myCmap)
		pause(0.2);
	end

	if save_figure
		FileName = ['ImgNo', num2str(i) , '_X_true'];
		export_fig(gcf,  [FileName, FigFormat], '-nocrop', '-transparent')   % export_fig(figure_handle, filename, , '-nocrop', '-transparent');		
	end

	%------------------------------------------------
	%% ------------------------------------------------
	% compute the residual and show the difference with goundtruth
	% Use image, not imagesc to show the residual, as the latter will normalize the error
	% -----------------------------
	% Truth - rec with SI
	imX = abs(Result_cell{i}.Iout1.A) ;
	imX = im2double(imX);
	X_GT = im2double(X_GT);
	imX_resid = abs(X_GT - imX);

	[imWhole,imPiece] = ShowFigInFig(imX_resid, PosStart, wSize, lineSize, BoxColor);
	imWhole(:,:,2:3) = [];	imPiece(:,:,2:3) = [];

	if show_figure
		cmin = 0; cmax = 0.3; % min and max color value threshold;
		figure;
		imagesc(imWhole); hold on;
		set(gcf,'Position', [300,200,size(imWhole,2)*1.2, size(imWhole,1)]); axis off
		set(gca, 'Position', [0,0,1/1.2,1]);
		set(gcf, 'Color', 'w'); % set figure background to be white
		colormap(jet); caxis([cmin, cmax]) ;
		c = colorbar ; c.LineWidth = 0.5; c.FontSize = 11; c.Position = [1/1.2, 0.02, 0.05, 0.96]; % [left, bottom, width, height]

		axes('Position',[0,0,0.4*size(imWhole,1)/size(imWhole,2)/1.2, 0.4]); 
		imagesc(imPiece); axis off
		colormap(jet); caxis([cmin, cmax]) ;
		pause(0.2);
	end
% 			myCmap = colormap(jet); % change the colormap for residual to be jet.

	if save_figure
		FileName = [FileNameCom , '_X_resid_', MethodNames{1}];
		export_fig(gcf,  [FileName, FigFormat], '-nocrop', '-transparent')   % export_fig(figure_handle, filename, , '-nocrop', '-transparent');		
	end


	%% compute SSIM
	mssim = []; ssim_map = [];
	imX = im2double(imX); 
	X_GT = im2double(X_GT); 
	[mssim, ssim_map] = ssim(imX, X_GT) ;

	[imWhole,imPiece] = ShowFigInFig(ssim_map, PosStart, wSize, lineSize, BoxColor);
	imWhole(:,:,2:3) = [];	imPiece(:,:,2:3) = [];


	if show_figure
		cmin = 0; cmax = 1; % min and max color value threshold;
		figure;
		imagesc(imWhole); hold on;
		set(gcf,'Position', [600,200,size(imWhole,2)*1.2, size(imWhole,1)]); axis off
		set(gca, 'Position', [0,0,1/1.2,1]);
		set(gcf, 'Color', 'w'); % set figure background to be white
		colormap(jet); caxis([cmin, cmax]) ;
		c = colorbar ; c.LineWidth = 0.5; c.FontSize = 11; c.Position = [1/1.2, 0.02, 0.05, 0.96]; % [left, bottom, width, height]

		axes('Position',[0,0,0.4*size(imWhole,1)/size(imWhole,2)/1.2, 0.4]); 
		imagesc(imPiece); axis off
		colormap(jet); caxis([cmin, cmax]) ;
		pause(0.2);
	end

	if save_figure
		FileName = [FileNameCom , '_X_ssimmap_', MethodNames{1}];
		export_fig(gcf,  [FileName, FigFormat], '-nocrop', '-transparent')   % export_fig(figure_handle, filename, , '-nocrop', '-transparent');		
	end
end

close all;




