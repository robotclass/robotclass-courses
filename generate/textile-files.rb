# just 'files' array with textile files

@@parts = [] # {:name=> 'name', :files=>[] }
# 'name'.html + 'name2'.html + ...  => one.pdf


@@names2file_name = {}

@@parts << { 
  :name=> 'home', 
  :files=> ['home.textile']
}
@@names2file_name['home'] = '_home.html'

in_folder = '01_base_gpio_raspberrypi'
files0 = %w[
  01_base_raspberrypi.textile
  02_out_led.textile
].map{|file_name| in_folder + '/' + file_name }

@@parts << { 
  :name=> in_folder, 
  :files=> files0
}
@@names2file_name['01_base_gpio_raspberrypi'] = '01_base_gpio_raspberrypi.html'

