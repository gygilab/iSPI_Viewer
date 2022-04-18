function setGene(gene) {
  Shiny.setInputValue('js_protein', gene);
}

$(document).on('shiny:connected', function() {
  var show_unquantified = false;

  Shiny.setInputValue('show_unquantified', show_unquantified);
  Shiny.setInputValue('smileWidth', $('#smiles').width());
  Shiny.setInputValue('titleHeight', $('#comp_name').height());
  Shiny.setInputValue('detailHeight', $('#comp_detail').height());
  Shiny.setInputValue('smileText_Height', $('#comp_smileText').height());

  $(window).resize(function(){
	Shiny.setInputValue('smileWidth', $('#smiles').width());
	Shiny.setInputValue('titleHeight', $('#comp_name').height());
	Shiny.setInputValue('detailHeight', $('#comp_detail').height());
	Shiny.setInputValue('smileText_Height', $('#comp_smileText').height());
  });

  Shiny.addCustomMessageHandler('setTitle', function(title){
	$('#comp_name').text(title.cmpd_name);
	let height = $('#comp_name').height();
	Shiny.setInputValue('titleHeight', height);
	$('#smiles').height(400 - height);

	$('#comp_detail').text(title.cmpd_detail);
	let height_detail = $('#comp_detail').height();
	Shiny.setInputValue('detailHeight', height_detail);
	$('#smiles').height(400+height_detail);

	$('#comp_smileText').text(title.cmpd_smile);
	let height_smileText = $('#comp_smileText').height();
	Shiny.setInputValue('smileText_Height', height_smileText);
	$('#smiles').height(410+height_smileText);
	});

  let showingSiteTable = true;
  let showingCompTable = true;
  $('#site_table_link').click(function(){
	if(showingSiteTable){
		$('#site_table').hide();
	} else {
		$('#site_table').show();
	}
	showingSiteTable = !showingSiteTable;
  });

  $('#comp_table_link').click(function(){
	if(showingCompTable){
		$('#comp_table').hide();
	} else {
		$('#comp_table').show();
	}
	showingCompTable = !showingCompTable;
  });

  $('#compound_input label').html('<span>#</span> of Compounds');

  $('#compound_input label span').click(function(){
	show_unquantified = !show_unquantified;
	Shiny.setInputValue('show_unquantified', show_unquantified);
  });


  let smilesDrawer = new SmilesDrawer.Drawer({ width: 400, height: 370 });

  Shiny.addCustomMessageHandler("smileHandler", function(smile) {
     SmilesDrawer.parse(smile,
                        function (tree) {
                            smilesDrawer.draw(tree, 'molecule-canvas', 'light', false);
                        },
                        function (err) {
                            console.log(err);
                        });
  });
});
