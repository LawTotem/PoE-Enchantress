from heapq import merge
import tensorflow as tf
from tensorflow.keras import datasets, layers, models
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import numpy as np
import json

valid_characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ-' ";

vi = [ord(aa) for aa in valid_characters]

targets = json.load(open('../targets.json','r'));
quals = targets['Heist Quals'];
mapping = layers.StringLookup(vocabulary=quals);
mapping2 = layers.IntegerLookup(vocabulary=tf.constant(vi))
char_to_num = layers.StringLookup(vocabulary=list(valid_characters));
num_to_char = layers.StringLookup(vocabulary=char_to_num.get_vocabulary(), invert=True);
cell_size = 256
img_size = (50, 1000, 1)
scale_size = (25, 250)
win_size = 32;
max_chars = 50;
num_chars = 30;

def get_gems(sub_dir) :
    labeling = json.load(open(sub_dir + "/labeling.json",'r'));
    gems = labeling #[l for l in labeling if l["type"] == "Heist Gem"]
    return (sub_dir,gems)

def get_raw_images(sd_gem) :
    sub_dir = sd_gem[0];
    gems = sd_gem[1];
    raw_images = [tf.image.rgb_to_grayscale(tf.keras.utils.load_img(sub_dir + '/' + l['name'])) for l in gems];
    return raw_images;


def get_raw_image_names(sd_gem) :
    sub_dir = sd_gem[0];
    gems = sd_gem[1];
    raw_images = [sub_dir + '/' + l['name'] for l in gems];
    return raw_images;

def resize_image(img, target_size) :
    ia =  tf.image.resize(img, target_size, preserve_aspect_ratio=True);
    return tf.image.pad_to_bounding_box(ia, 0, 0, target_size[0], target_size[1]);

def get_images(sd_gem) :
    raw_images = get_raw_images(sd_gem);
    images = [resize_image(tf.keras.utils.img_to_array(ri),(img_size[0],img_size[1])) for ri in raw_images];
    return images

def get_image_tensors(sd_gem) :
    images = get_images(sd_gem);
    image_set = tf.data.Dataset.from_tensors(images);
    return image_set;

def convert_lbl(gg) :
    if "text" in gg : return gg["text"]
    return gg["qual"] + " " + gg["gem"]

def get_raw_labels(sd_gem) :
    gems = sd_gem[1];
    lbls = []
    lbl = [convert_lbl(l).upper().replace(" ","") for l in gems];
    return lbl;
    #return char_to_num(tf.strings.unicode_split(lbl, input_encoding="UTF-8"))
    #lfull = [[f[i] for i in range(num_chars)] for f in full];
    #lfull = [f[0] for f in full];
    #return mapping2(full);

def get_labels(sd_gem) :
    labels = get_raw_labels(sd_gem);
    label_set = tf.data.Dataset.from_tensors(labels);
    return label_set;

def get_combined(sub_dir) :
    gems = get_gems(sub_dir);
    label_set = get_raw_labels(gems);
    image_set = get_raw_image_names(gems);
    return (label_set, image_set)

def load_fix_img(file_name) :
    img_f = tf.keras.utils.img_to_array(tf.keras.utils.load_img(file_name));
    gray_img = tf.image.rgb_to_grayscale(img_f);
    size_image = tf.image.resize(gray_img, (img_size[0], img_size[1]), preserve_aspect_ratio=True);
    pad_image = tf.image.pad_to_bounding_box(size_image, 0, 0, img_size[0], img_size[1]);
    contrast_image = tf.image.random_contrast(pad_image, 0.9, 1.1);
    return pad_image

def fix_label(lbl) :
    return lbl.upper().replace(" ","");
    label = tf.strings.unicode_split(label, input_encoding="UTF-8");
    label = char_to_num(label);
    return label

def join_combined(combos) :
    lbls = sum([c[0] for c in combos],[]);
    lbls = char_to_num(tf.strings.unicode_split([fix_label(c) for c in lbls],input_encoding="UTF-8"));
    imgs = sum([c[1] for c in combos],[]);
    imgs = [load_fix_img(i) for i in imgs];
    dset = tf.data.Dataset.from_tensor_slices((imgs, lbls));
    return dset.batch(64)


base_training = "E:/EnchantressTraining/RandomGems/"
in_game = "../Ingame/Heist_Shorts/"
sub_folders = ['p2','p3','p4','p5','p6'];
#sub_folders = ['p2']
sub_training = [get_combined(base_training + sf + '/') for sf in sub_folders];
sub_folders = ['p5','p6','p7','p8','p9','p10','p11','p12','p13','p14','p15','p16','p17','p18','p19','p20','p21','p22'];
sub_training = sub_training + [get_combined(in_game + sf + '/') for sf in sub_folders];
base_training = "E:/EnchantressTraining/RandomRares/"
sub_folders = ['p1','p2'];
sub_training = sub_training + [get_combined(base_training + sf + '/') for sf in sub_folders];
base_training = "E:/EnchantressTraining/RandomUniques/"
sub_folders = ['p1','p2'];
sub_training = sub_training + [get_combined(base_training + sf + '/') for sf in sub_folders];
training = join_combined(sub_training);

print(training)

base_training = "E:/EnchantressTraining/RandomGems/"
sub_val = [get_combined(base_training + 'p1/')];
sub_folders = ['p1','p2','p3','p4','p23'];
sub_val = sub_val + [get_combined(in_game + sf + '/') for sf in sub_folders];
val = join_combined(sub_val);

#model = models.load_model('heist_qual.tf')


#mm = 2
#if mm == 1:
#    model = models.Sequential()
#    model.add(layers.Input((100,500,3)))
#    model.add(layers.Rescaling(1./255))
#    model.add(layers.Dropout(0.04))
#    model.add(layers.Resizing(50,250))
#    #model.add(layers.RandomRotation(0.1))
#    #model.add(layers.RandomZoom(0.25))

#    #model.add(layers.Conv2D(32, 8, activation='relu'))
#    #model.add(layers.MaxPooling2D((5,5)))
#    #model.add(layers.Conv2D(32, (8,32), activation='relu'))

#    model.add(layers.Conv2D(32, 8, activation='relu'))
#    model.add(layers.MaxPooling2D(8,8))
#    model.add(layers.Conv2D(32, (4,16), activation='relu'))
#    #model.add(layers.MaxPooling2D(3))

#    #model.add(layers.MaxPooling2D((10,5)))
#    #model.add(layers.Dropout(0.1));
#    model.add(layers.Flatten());
#    model.add(layers.Dense(len(quals)+1));
#elif mm ==  2 :

#   ## Build Emmision Network

#Layer that can cut a portion of the image

i_i = layers.Input(img_size, name='input_image');
i_r = layers.Rescaling(1./255, name='rescale_image')(i_i);
#i_c = layers.RandomContrast([0.9,1.1])(i_r);

#c_c1 = layers.Conv2D(128,10,activation='relu')(i_c);
#c_p1 = layers.MaxPooling2D((5,5))(c_c1);

c_c1 = layers.Conv2D(64,5,activation='relu', name='conv2d1')(i_i);
c_p1 = layers.MaxPooling2D((2,2), name='pool1')(c_c1);
c_c2 = layers.Conv2D(128,5,activation='relu',name='conv2d2')(c_p1);
c_p2 = layers.MaxPooling2D((2,2),name='pool2')(c_c2);
c_c3 = layers.Conv2D(256,5,activation='relu',name='conv2d3')(c_p2);
c_n1 = layers.BatchNormalization(name='normalize')(c_c3);
c_p3 = layers.MaxPooling2D((1,2),name='pool3')(c_n1);
t_p1 = layers.Permute((2,1,3),name='permute')(c_p3);

#t_p1 = layers.Permute((2,1,3))(c_p1);

t_r1 = layers.Reshape((t_p1.shape[1],-1),name='flatten')(t_p1);
2
b_1 = layers.Bidirectional(layers.GRU(128, return_sequences=True, name='gru1'), merge_mode='sum',name='bidirect1')(t_r1, initial_state=None);
b_2 = layers.Bidirectional(layers.GRU(128, return_sequences=True, name='gru2'), merge_mode='concat',name='bidirect2')(b_1, initial_state=None);

dm = layers.Dense(len(valid_characters) + 1, activation='softmax', name='to_chars')(b_2);

model = models.Model(inputs=[i_i],outputs=[dm]);
def CTCLoss(y_true, y_pred):
    # Compute the training-time loss value
    batch_len = tf.cast(tf.shape(y_pred)[0], dtype="int64")
    y_true = y_true[0:batch_len];
    input_length = tf.cast(tf.shape(y_pred)[1], dtype="int64")
    #label_length = tf.cast(tf.shape(y_true)[1], dtype="int64")
    label_length = y_true.row_lengths()
    input_length = input_length * tf.ones(shape=(batch_len, 1), dtype="int64")
    label_length = tf.reshape(label_length, (batch_len, 1))
    f_y_true = y_true.to_tensor();
    #label_length = label_length * tf.ones(shape=(batch_len, 1), dtype="int64")
    loss = tf.compat.v1.keras.backend.ctc_batch_cost(f_y_true, y_pred, input_length, label_length)
    return loss


model.compile(optimizer='adam', loss=CTCLoss);
#model.compile();

print(model.summary())
history = model.fit(training, validation_data=val, epochs = 10, use_multiprocessing=True);

#model.save('heist_qual.tf');
#model.save_weights("heist_gem.w.tf");
#model.save("heist_gem_h5.tf", save_format='h5')
model.save("heist_ocr.tf");



#tf.keras.models.save_model(model, "heist_gem.tf")

#model = models.load_model('heist_qual.tf')


def ctc_map(bstr) :
    bstr = bstr.numpy()
    rstr = b'';
    lstchar = b' '
    for k in range(len(bstr)) :
        if bstr[k] == lstchar :
            continue;
        lstchar = bstr[k];
        if lstchar == b' ' :
            continue;
        rstr = rstr + lstchar
    return rstr

# model.load_weights("heist_gem.w.tf")
ii = load_fix_img(sub_val[0][1][1])
aa = model.predict(tf.data.Dataset.from_tensors([ii]))
ctc_map(num_to_char(np.argmax(aa[0],1)))