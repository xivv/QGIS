import os.path
from qgis.core import *

from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyQt4.QtSql import *
import resources
from simulation_dlg import simulationDialog
import simulation_dlg
from ftplib import print_line
from processing.core.Processing import Processing
Processing.initialize()
from processing.tools import *

class Workshop:

	def __init__(self,iface):
		self.iface = iface
	
	def initGui(self):
		icon_path = ':/plugins/workshopplugin/icon1.png'
		self.add_action(
            icon_path,
            text=self.tr(u''),
            callback=self.run,
            parent=self.iface.mainWindow())
			
		self.action = QAction(QIcon(":/plugins/workshopplugin/icon1.png"),"Gas Simulation",self.iface.mainWindow())
		
		QObject.connect(self.action, SIGNAL("activated()"),self.run)
		
		self.iface.addToolBarIcon(self.action)
		self.iface.addPluginToMenu("Gas Simulation",self.action)
		
	def tr(self, message):
    	 return QCoreApplication.translate('workshop', message)
		
	def add_action(
        self,
        icon_path,
        text,
        callback,
        enabled_flag=True,
        add_to_menu=True,
        add_to_toolbar=True,
        status_tip=None,
        whats_this=None,
        parent=None):
		self.dlg = simulationDialog()
		
	
	def unload(self):
		self.iface.removePluginMenu('&Gas Simulation', self.action)
		self.iface.removeToolBarIcon(self.action)
		
	def run(self):
	   	
		layer = self.iface.mapCanvas().currentLayer()
		nodes = "";
		
		if not layer or not (layer.name() == 'node') :
			QMessageBox.information(None,"Simulation","Select the nodelayer")
			return
		
		selected = layer.selectedFeatures()
		
		if not selected:
			QMessageBox.information(None,"Simulation","Select a starting node")
			return
			
		if selected:
			idx = layer.fieldNameIndex('node_id')
			print("Selected")
		 	for node in selected:
		 		nodes = nodes + str(node.attributes()[idx]) + ",";
		 		
		nodes = nodes[:-1];
		print nodes;
		 	
		#DataBaseInformation
		db = QSqlDatabase('QPSQL')
		if db.isValid():
   			db.setHostName('localhost')
    	 	db.setDatabaseName('mgc_data')
  	    	db.setUserName('postgres')
      	 	db.setPassword('postgres')
      	 	db.setPort(5432)
      	 	
  	 		
  	 	if db.open():
  	 		# Add all possible tables from the topology
  	 		query = db.exec_("SELECT DISTINCT table_name FROM information_schema.columns WHERE table_schema = 'gas_test' AND table_name <> 'node' AND table_name <> 'relation' AND table_name <> 'face' AND table_name <> 'edge_data' AND table_name <> 'edge'")
  	 		self.dlg.comboBox.clear()
  	 		while query.next():
  	 			record = query.record()
  	 			self.dlg.comboBox.addItem(record.value(0))
  	 			
  	 			
  	 		# Add all possible fields from the table (schieber)
  	 		query = db.exec_("SELECT column_name FROM information_schema.columns WHERE table_schema = 'gas_test' AND table_name = 'absperrarmatur'")
  	 		self.dlg.comboBox_2.clear()
  	 		while query.next():
  	 			record = query.record()
  	 			self.dlg.comboBox_2.addItem(record.value(0))
  	 			
  	 		# Add all possible criteriums from the field (schieber)
  	 		query = db.exec_("SELECT DISTINCT armaturenstellung FROM gas_test.absperrarmatur")
  	 		self.dlg.comboBox_3.clear()
  	 		while query.next():
  	 			record = query.record()
  	 			self.dlg.comboBox_3.addItem(record.value(0))
  	 		
  	 			
 		self.dlg.show()
	 	result = self.dlg.exec_()
		
		if result:
			
			layer = self.iface.mapCanvas().currentLayer()
			if not (layer.name() == "edge_data") :
				QMessageBox.information(None,"Simulation","Select the edge layer")
				return
		
			table = self.dlg.comboBox.currentText()
			attribute = self.dlg.comboBox_2.currentText()
			criterium = self.dlg.comboBox_3.currentText()
			topology = "gas_test"
			
			print "Simulation start"
			result=[]
			if db.open():
	   			query = db.exec_(" select * from topology.simulate(\'" + nodes + "\',\'" + topology + "\',\'" + table + "\',\'" + attribute + "\',\'" + criterium + "\')")
	   			while query.next():
	   				record = query.record()	   	
	   				result.append(record.value(0))			
	   			print "Simulation end"
	   			
	   			layer = self.iface.mapCanvas().currentLayer()
	   			idx2 = layer.fieldNameIndex('edge_id')
	   			
	   			
	   			
	   			selection=[]
	   			
	   			for resulted in result:
	   				request = QgsFeatureRequest().setFilterExpression(u'"edge_id" = ' + str(resulted))
	   				request.setFlags(QgsFeatureRequest.NoGeometry).setSubsetOfAttributes(['id'], layer.fields())
	   				for feature in layer.getFeatures(request):
	   					selection.append(feature.id())
	   				
	   					
	   			
	   			#Find all edges that the simulation found and select them
	   			#for feature in layer.getFeatures(request):
	   				#if (feature.attributes()[idx2] in result):
	   				#selection.append(feature.id())
	   					
	   					
	   		layer.setSelectedFeatures(selection)
	   		print "Selection end"
	   		## Create Temporary Layer ##
	   
			temp = QgsVectorLayer("LineString?crs=epsg:31468",self.dlg.layer_name.text(), "memory")
			temp_data = temp.dataProvider()
			attr = layer.dataProvider().fields().toList()
			temp_data.addAttributes(attr)
			temp.updateFields()
			temp_data.addFeatures(layer.selectedFeatures())
			QgsMapLayerRegistry.instance().addMapLayer(temp)
	   		print "Creation end"
	   		
	   	

			
