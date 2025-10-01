#!/usr/bin/env node

/**
 * Zellij Theme Generator
 * Converts theme.json to KDL format for Zellij configuration
 */

const fs = require('fs');
const path = require('path');

// Helper function to convert hex to RGB array
function hexToRgb(hex) {
  // Remove # if present
  const cleanHex = hex.startsWith('#') ? hex.slice(1) : hex;

  if (cleanHex.length === 6) {
    return [
      parseInt(cleanHex.slice(0, 2), 16),
      parseInt(cleanHex.slice(2, 4), 16),
      parseInt(cleanHex.slice(4, 6), 16)
    ];
  }

  throw new Error(`Invalid hex color: ${hex}`);
}

// Helper function to parse color value
function parseColor(value, palette) {
  // If it's a palette reference (no # prefix), look it up
  if (!value.startsWith('#') && palette[value]) {
    const paletteColor = palette[value];
    // Support both old format (with rgb) and new format (value only)
    if (paletteColor.rgb) {
      return paletteColor.rgb;
    }
    if (paletteColor.value) {
      return hexToRgb(paletteColor.value);
    }
    // If palette entry is just a string
    if (typeof paletteColor === 'string') {
      return hexToRgb(paletteColor);
    }
  }

  // If it's already an array, return it
  if (Array.isArray(value)) {
    return value;
  }

  // If it's a hex color, convert to RGB
  if (value.startsWith('#')) {
    return hexToRgb(value);
  }

  throw new Error(`Unable to parse color: ${value}`);
}

// Helper function to format a component section
function formatComponent(name, component, palette) {
  const lines = [`        ${name} {`];

  // Process each color property
  ['base', 'background', 'emphasis_0', 'emphasis_1', 'emphasis_2', 'emphasis_3'].forEach(prop => {
    if (component[prop]) {
      const rgb = parseColor(component[prop], palette);
      lines.push(`            ${prop} ${rgb[0]} ${rgb[1]} ${rgb[2]}`);
    }
  });

  lines.push('        }');
  return lines.join('\n');
}

// Main generation function
function generateTheme(inputFile, outputFile) {
  try {
    // Read and parse JSON
    const jsonContent = fs.readFileSync(inputFile, 'utf8');
    const theme = JSON.parse(jsonContent);

    const { metadata, palette, components, multiplayer_user_colors } = theme;

    // Start building KDL output
    let kdl = `// ${metadata.description}\n`;
    kdl += `// Author: ${metadata.author}\n`;
    kdl += `// Version: ${metadata.version}\n`;
    kdl += `// Generated from theme.json on ${new Date().toISOString().split('T')[0]}\n\n`;

    kdl += `themes {\n`;
    kdl += `    ${metadata.name} {\n`;

    // Generate each component
    const componentNames = [
      'text_unselected',
      'text_selected',
      'ribbon_unselected',
      'ribbon_selected',
      'table_title',
      'table_cell_unselected',
      'table_cell_selected',
      'list_unselected',
      'list_selected',
      'frame_unselected',
      'frame_selected',
      'frame_highlight',
      'exit_code_success',
      'exit_code_error'
    ];

    componentNames.forEach(name => {
      if (components[name]) {
        kdl += formatComponent(name, components[name], palette) + '\n';
      }
    });

    // Generate multiplayer colors
    if (multiplayer_user_colors && multiplayer_user_colors.colors) {
      const colorValues = multiplayer_user_colors.colors
        .flatMap(c => c.rgb)
        .join(' ');
      kdl += `        multiplayer_user_colors ${colorValues}\n`;
    }

    kdl += `    }\n`;
    kdl += `}\n`;

    // Write output
    fs.writeFileSync(outputFile, kdl, 'utf8');

    console.log(`✓ Theme generated successfully!`);
    console.log(`  Input:  ${inputFile}`);
    console.log(`  Output: ${outputFile}`);
    console.log(`\nTo use this theme, add to your config.kdl:`);
    console.log(`  theme "${metadata.name}"`);

  } catch (error) {
    console.error(`✗ Error generating theme: ${error.message}`);
    process.exit(1);
  }
}

// Function to update config.kdl with generated theme
function updateConfig(themeKdl, configFile) {
  try {
    const configContent = fs.readFileSync(configFile, 'utf8');

    // Extract just the theme content (without the outer themes { } wrapper)
    const themeMatch = themeKdl.match(/themes\s*\{([\s\S]*)\}/);
    if (!themeMatch) {
      throw new Error('Could not parse generated theme');
    }

    // Replace the themes block in config
    const updatedConfig = configContent.replace(
      /themes\s*\{[\s\S]*?\n\}/m,
      `themes {${themeMatch[1]}}`
    );

    fs.writeFileSync(configFile, updatedConfig, 'utf8');
    console.log(`✓ Config updated: ${configFile}`);

  } catch (error) {
    console.error(`✗ Error updating config: ${error.message}`);
    console.log('  You can manually copy theme.kdl content to config.kdl');
  }
}

// CLI handling
const args = process.argv.slice(2);
const inputFile = args[0] || path.join(__dirname, 'theme.json');
const outputFile = args[1] || path.join(__dirname, 'theme.kdl');
const configFile = path.join(__dirname, 'config.kdl');

generateTheme(inputFile, outputFile);

// Also update config.kdl if it exists
if (fs.existsSync(configFile)) {
  const themeKdl = fs.readFileSync(outputFile, 'utf8');
  updateConfig(themeKdl, configFile);
}