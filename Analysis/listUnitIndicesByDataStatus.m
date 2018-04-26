function [ datafiles_index_vectors_cell, categories_cell, numCategories] = listUnitIndicesByDataStatus(unitArray)
% [ datafiles_index_vectors_cell, categories_cell, numCategories] = listUnitIndicesByDataFiles(unitArray)
% super shitty just need it now

    rigdefs = RigDefs;
    [datafiles_index_vectors_cell, categories_cell, numCategories] ...
        = listUnitIndicesByFcn(unitArray, @unitHasDaqFiles, 1);
    all_index_vectors = sort(datafiles_index_vectors_cell{:}, 'ascend');
    
    if(~all(all_index_vectors == 1:length(unitArray)))
        % missing spikes/expt files
        missing = find(~ismember(1:length(unitArray), all_index_vectors));
        datafiles_index_vectors_cell{end+1} = missing;
        categories_cell{end+1} = 'missing spikes or expt';
    end
    disp([num2str(length(unitArray)), ' units:']);
    for(catIdx = 1:length(categories_cell))
        disp(['   ', num2str(length(datafiles_index_vectors_cell{catIdx})), ' ', categories_cell{catIdx}]);
    end
    
    function category_str = unitHasDaqFiles(unit, curExpt, curTrodeSpikes)
        fileInds = unique(curTrodeSpikes.fileInd(ismember(curTrodeSpikes.assigns, unit.assign)));
        hasDaq = 1;
        for(idx = 1:length(fileInds))
            fname = fullfile(rigdefs.Dir.Data, curExpt.files.names{fileInds(idx)});
            if(~exist(fname, 'file'))
                hasDaq = 0;
                break;
            end
        end  
        strs = {'all data', 'spikes, expt, but no daq'};
        category_str = strs{2-hasDaq};
    end
end