function comboList = getComboList(num)

choiceList = 1:num;
comboList = nchoosek(choiceList,2);

end