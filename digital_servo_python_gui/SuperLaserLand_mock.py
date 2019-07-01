import numpy as np

from SuperLaserLand_JD_RP import SuperLaserLand_JD_RP


# This is a subclass of SuperLaserLand_JD_RP, and we simply override
# the methods that would not work without a physical setup attached.
class SuperLaserLand_mock(SuperLaserLand_JD_RP):


	def __init__(self):
		super(SuperLaserLand_mock, self).__init__()
		pass

	def setup_write(self, selector, Num_samples):

		self.Num_samples_write = int(Num_samples)  # no such restriction with the Red Pitaya implementation
		self.Num_samples_read = self.Num_samples_write
		self.last_selector = selector
	
	# def setup_ADC0_write(self, Num_samples):
	# 	self.setup_write(self.SELECT_ADC0, Num_samples)
	# def setup_ADC1_write(self, Num_samples):
	# 	self.setup_write(self.SELECT_ADC1, Num_samples)
	# def setup_DAC0_write(self, Num_samples):
	# 	self.setup_write(self.SELECT_DAC0, Num_samples)
	# def setup_DAC1_write(self, Num_samples):
	# 	self.setup_write(self.SELECT_DAC1, Num_samples)
	# def setup_DAC2_write(self, Num_samples):
	# 	self.setup_write(self.SELECT_DAC2, Num_samples)

	def read_adc_samples_from_DDR2(self):
		# TODO: need to return a representative test vector (tone + noise maybe?)
		samples_out = 0.1*np.cos(2*np.pi*25e6/self.fs*np.arange(0., self.Num_samples_read))
		# add noise, but keep the same seed everytime for repeatable results:
		np.random.seed(0)
		samples_out = samples_out + 1e-3 * np.random.randn(self.Num_samples_read)
		samples_out = np.round(2.**(16-1) * samples_out)
		ref_exp0 = 1. + 0.j
		return (samples_out, ref_exp0)

	# these don't need to do anything at the level of simulation we are choosing
	def trigger_write(self):
		pass
	def wait_for_write(self):
		pass