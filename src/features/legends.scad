module keytext(text, position, font_size, depth) {
  woffset = (top_total_key_width()/3.5) * position[0];
  hoffset = (top_total_key_height()/3.5) * -position[1];
  translate([woffset, hoffset, -depth]){
    color($tertiary_color) linear_extrude(height=$dish_depth + depth){
      text(text=text, font=$font, size=font_size, halign="center", valign="center");
    }
  }
}

module cylindertext(text, size, font, r=undef, d=undef, pos=0, outside=true, extrude_height=4, extrude_center=true, text_halign="center", text_valign="baseline") {
  sgn = outside ? 1 : -1;
  r = is_undef(d) ? r : d / 2;
  tm = textmetrics(text=text, font=font, size=size);
  theta_total = sgn * tm.advance[0] * (180 / PI) / r;
  rotate(
    text_halign == "left" ? 0 :
    text_halign == "right" ? -theta_total :
    -theta_total / 2)
  cylindertext1(text, size, font, r, pos, outside, extrude_height, extrude_center, text_valign);
}

module cylindertext1(text, size, font, r, pos, outside, extrude_height, extrude_center, text_valign) {
  sgn = outside ? 1 : -1;
  if (pos < len(text)) {
    c = text[pos];

    m = textmetrics(text=c, font=font, size=size);
    theta_advance = sgn * m.advance[0] * (180 / PI) / r;
    rotate(theta_advance/2+90)
    translate([0,r,0])
    rotate(outside ? 180 : 0)
    rotate([90,0,0])
    linear_extrude(height=extrude_height, center=extrude_center)
    text(c, size=size, font=font, halign="center", valign=text_valign);

    rotate(theta_advance)
    cylindertext1(text, size, font, r, pos=pos+1, outside=outside, extrude_height=extrude_height, extrude_center=extrude_center);  
  }
}

module keytext_cylindrical(text, position, font_size, depth) {
  woffset = (top_total_key_width()/3.5) * position[0];
  hoffset = (top_total_key_height()/3.5) * -position[1] - font_size/2;
  // copied from module _dish()
  dish_width = top_total_key_width() + $dish_overdraw_width;
  dish_height = top_total_key_height() + $dish_overdraw_height;
  dish_rad = cylindrical_dish_radius(width=dish_width, depth=$dish_depth);
  // XXX inverted legends
  chord_length = cylindrical_dish_chord_length(width=dish_width, depth=$dish_depth);
  dish_circumference = 6.283 * dish_rad;
  theta = 90-woffset * 360 / dish_circumference;
  translate([$dish_offset_x,0,chord_length]) {
  mirror([1,0,0])
  rotate(180)
  rotate([90,0,0])
    color($tertiary_color) {
      translate([0,0,hoffset])
      rotate(theta)
      cylindertext(
        text=text,
        font=$font,
        size=font_size,
        r=dish_rad,
        extrude_height = 2*depth,
        extrude_center = true,
        text_halign="center");
//    size=font_size,
//    r=dish_rad-.1,
//    h=top_total_key_height()/3.5,
//    updown=hoffset,
//    eastwest=theta,
//    face=$font, size=font_size,
//    // unsupported: halign="center", valign="center",
//    center=false,
//    cylinder_center=true,
//    extrusion_center=true,
//    extrusion_height = 2*depth,
//    rotate=0);
    }
  }
}

module legends(depth=0) {
  if (len($front_legends) > 0) {
    front_of_key() {
      for (i=[0:len($front_legends)-1]) {
        rotate([90,0,0]) keytext($front_legends[i][0], $front_legends[i][1], $front_legends[i][2], depth);
  	  }
    }
  }
  if (len($legends) > 0) {
    if($dish_type == "cylindrical"){
    top_placement()
        for (i=[0:len($legends)-1]) {
          keytext_cylindrical($legends[i][0], $legends[i][1], $legends[i][2], depth);
        }
    } else {
      top_of_key() {
        for (i=[0:len($legends)-1]) {
          keytext($legends[i][0], $legends[i][1], $legends[i][2], depth);
        }
      }
    }
  }
}
